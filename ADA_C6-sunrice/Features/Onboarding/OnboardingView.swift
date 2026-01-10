
import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel(totalPages: 3)
    var onFinish: () -> Void = {}
    
    var body: some View {
        // Content
        VStack(spacing: 16) {
            // Header
            Header(config: .init(
                showsBackButton: vm.canGoBack,
                trailing: .skip(action: { vm.skipToEnd() })
            )) {
                withAnimation(.spring(
                    duration: 0.35,
                    bounce: 0.35,
                    blendDuration: 0.35)
                ) {
                    vm.back()
                }
            }

            // Content
            TabView(selection: $vm.page) {
                OnboardingPage1View()
                    .tag(0)
                OnboardingPage2View()
                    .tag(1)
                OnboardingPage3View()
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Stepper indicators
            PageIndicator(totalPages: vm.totalPages, currentPage: $vm.page)

            // Controls
            Spacer(minLength: 0)
            
            AppButton(title: vm.primaryButtonTitle) {
                withAnimation(.spring(
                    duration: 0.35,
                    bounce: 0.35,
                    blendDuration: 0.35)) { vm.next() }
            }
        }
        .onChange(of: vm.didFinish) { _, newValue in
            if newValue { onFinish() }
        }
        .padding()
        .background(
            Background()
        )
    }
}

#Preview {
    OnboardingView()
}
