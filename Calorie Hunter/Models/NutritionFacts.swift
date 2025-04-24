import Foundation

/// Parsed macro information extracted from the OCR text of a nutrition label.
struct NutritionFacts {
    
    // MARK: – public results
    var calories: Int?     // kcal
    var protein : Double?  // g
    var carbs   : Double?  // g
    var fat     : Double?  // g
    
    // MARK: – initialiser
    init(from text: String, debug: Bool = false) {
        
        // ── tiny helpers ────────────────────────────────────────────────
        func log(_ m: @autoclosure () -> String) { if debug { print(m()) } }
        
        let lines = text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        func lower(_ s: String) -> String {
            s.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        }
        func numeric(in str: String) -> Double? {
            let pat = #"[0-9]+(?:[.,][0-9]+)?"#
            guard let r = str.range(of: pat, options: .regularExpression) else { return nil }
            return Double(str[r].replacingOccurrences(of: ",", with: "."))
        }
        
        // ── 1. classify headline rows … (unchanged) ─────────────────────
        enum Row { case cal, fat, satFat, carb, sugar, fiber, prot, salt, other }
        
        func rowType(of line: String) -> Row? {
            let l = lower(line)
            guard numeric(in: l) == nil else { return nil }  // numbers ⇒ not headline
            
            if l.contains("energie")   || l.contains("brennwert") || l.contains("calorie") { return .cal }
            if l.contains("fett")      && !l.contains("davon")                                 { return .fat }
            if l.contains("gesättigt") || l.contains("gesaettigt")
                || l.contains("davon gesättigte") || l.contains("davon gesaettigte")            { return .satFat }
            if l.contains("kohlenhydrat") || l.contains("carbo")                               { return .carb }
            if l.contains("zucker")     &&  l.contains("davon")                                { return .sugar }
            if l.contains("ballaststoff") || l.contains("fibre")                               { return .fiber }
            if l.contains("eiwei")       || l.contains("protein")                              { return .prot }
            if l.contains("salz")                                                              { return .salt }
            return .other
        }
        
        var rowOrder: [Row] = []
        for l in lines { if let r = rowType(of: l) { rowOrder.append(r) } }
        log("row order detected → \(rowOrder)")
        
        // ── 2. collect value lines (fix is here) ────────────────────────
        struct ValueLine { let raw: String; let value: Double; let isKcal: Bool }
        var values: [ValueLine] = []
        
        for l in lines {
            guard let v = numeric(in: l) else { continue }
            let lo = lower(l)
            
            // skip “100 g enthält …”
            if lo.contains("100 g") && lo.contains("enthalt") { continue }
            
            let endsWithUnit =
            lo.hasSuffix(" g")   ||
            lo.hasSuffix("g")    ||
            lo.hasSuffix(" kcal") ||
            lo.hasSuffix("kcal") ||
            lo.hasSuffix(" kj")  ||
            lo.hasSuffix("kj")
            
            guard endsWithUnit else { continue }
            
            values.append(ValueLine(raw: l, value: v, isKcal: lo.contains("kcal")))
        }
        log("value lines kept → \(values.map { $0.raw })")
        
        // ── 3. walk rows & values in parallel … (unchanged) ─────────────
        var vIndex = 0
        for row in rowOrder {
            guard vIndex < values.count else { break }
            
            switch row {
                
            case .cal:
                while vIndex < values.count, !values[vIndex].isKcal { vIndex += 1 }
                guard vIndex < values.count else { break }
                calories = Int(values[vIndex].value)
                log("calories ← \(values[vIndex].value)  (line: “\(values[vIndex].raw)”)")
                vIndex += 1
                
            case .fat:
                fat = values[vIndex].value
                log("fat      ← \(values[vIndex].value)")
                vIndex += 1
                
            case .carb:
                carbs = values[vIndex].value
                log("carbs    ← \(values[vIndex].value)")
                vIndex += 1
                
            case .prot:
                protein = values[vIndex].value
                log("protein  ← \(values[vIndex].value)")
                vIndex += 1
                
            default:
                log("skip \(row)  (value \(values[vIndex].value))")
                vIndex += 1
            }
        }
        
        // ── optional summary (unchanged) ────────────────────────────────
        if debug {
            log("—— parsing result ——————————————————————————————")
            log("   calories: \(calories.map { String($0) } ?? "nil")")
            log("   fat     : \(fat.map { String($0) } ?? "nil") g")
            log("   carbs   : \(carbs.map { String($0) } ?? "nil") g")
            log("   protein : \(protein.map { String($0) } ?? "nil") g")
            log("———————————————————————————————————————————————")
        }
    }
}
