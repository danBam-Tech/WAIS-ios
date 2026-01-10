import SwiftUI

extension Font {
    // MARK: - SF Pro – Body & Labels

    /// Small body / description / helper text (SF Pro, 14, .regular)
    static let bodySM = Font.system(size: 14, weight: .regular, design: .default)

    /// Small body with emphasis (alert, etc) (SF Pro, 14, .semibold)
    static let bodySMEmphasis = Font.system(size: 14, weight: .semibold, design: .default)
    
    /// Tiny label (notifications, status, etc) (SF Pro, 12, .regular)
    static let labelTiny = Font.system(size: 12, weight: .regular, design: .default)

    /// Small labels (small buttons, badges, strong alerts) (SF Pro, 14, .bold)
    static let labelSM = Font.system(size: 14, weight: .bold, design: .default)

    /// Medium labels (buttons, numbers next to symbols, small subheadings) (SF Pro, 16, .bold)
    static let labelMD = Font.system(size: 16, weight: .bold, design: .default)

    /// Large input, for example PIN or name input (SF Pro, 32, .bold)
    static let inputXL = Font.system(size: 32, weight: .bold, design: .default)
    
    /// Extra Large input, for example PIN or name input (SF Pro, 64, .bold)
    static let inputXXL = Font.system(size: 64, weight: .bold, design: .default)
    
    /// Medium symbols or large numbers (SF Pro, 16, .regular)
    static let symbolM = Font.system(size: 16, weight: .regular, design: .default)

    /// Large symbols or large numbers (SF Pro, 24, .bold)
    static let symbolL = Font.system(size: 24, weight: .bold, design: .default)
}

extension Font {
    // MARK: - Manrope ExtraBold – Titles
    
    /// Title for label (Manrope-ExtraBold, 16)
    static let titleSSM = Font.custom("Manrope-ExtraBold",
                                    size: 16,
                                    relativeTo: .title3)

    /// Title indicating the current screen (Manrope-ExtraBold, 20)
    static let titleSM = Font.custom("Manrope-ExtraBold",
                                    size: 20,
                                    relativeTo: .title3)

    /// Title for splash, loading, storytelling screen (Manrope-ExtraBold, 24)
    static let titleMD = Font.custom("Manrope-ExtraBold",
                                    size: 24,
                                    relativeTo: .title2)

    /// Title special case / big hero (Manrope-ExtraBold, 32)
    static let titleLG = Font.custom("Manrope-ExtraBold",
                                    size: 32,
                                    relativeTo: .largeTitle)
}
