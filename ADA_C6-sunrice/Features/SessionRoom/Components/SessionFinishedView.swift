//
//  SessionFinishedView.swift
//  ADA_C6-sunrice
//
//  Created by Komang Wikananda on 26/11/25.
//

import SwiftUI
import Lottie

struct SessionFinishedView: View {
    @ObservedObject var vm: SessionRoomViewModel
    
    var body: some View {
        VStack (spacing: 24) {
            Spacer()
            
            VStack (spacing: 8) {
                Text("Session Finished!")
                    .font(.titleMD)
                Text("Lets see how everything went")
                    .font(.bodySM)
            }
            if vm.isAnalyzingIdeas {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text(vm.analysisProgress)
                        .font(.titleSSM)
                    
                    Text("Please wait...")
                        .font(.bodySM)
                        .foregroundColor(.secondary)
                }
            } else if let error = vm.analysisError {
                // Error state
                if vm.isHost {
                    // Host: Show error with retry button
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.titleSSM)
                                .foregroundColor(.red)
                            
                            Text("Analysis Failed")
                                .font(.titleSSM)
                                .foregroundColor(.red)
                        }
                        
                        Button {
                            Task {
                                await vm.analyzeIdeas()
                            }
                        } label: {
                            Label("Retry Analysis", systemImage: "arrow.clockwise")
                                .font(.bodySM)
                                .fontWeight(.semibold)
                                .padding()
                                .background(AppColor.Primary.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                } else {
                    // Guest: Keep showing loading (polling continues)
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Waiting for analysis...")
                            .font(.titleSSM)
                        
                        Text("Please wait...")
                            .font(.bodySM)
                            .foregroundColor(.secondary)
                    }
                }
            } else {
                Text("Analysis Complete!")
                    .font(.titleSSM)
            }
            
            LottieView(name: "splash_animation", loopMode: .loop)
                .frame(width: 350, height: 350)
            
            Spacer()
            
            if !vm.isAnalyzingIdeas {
                AppButton(title: "NEXT") {
                    vm.navigateToFinalSummary()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Background())
        .onAppear {
            if !vm.hasFetchedInsights {
                Task {
                    await vm.analyzeIdeas()
                }
            }
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onTapToDismissKeyboard()
    }
}

#Preview {
    // Preview requires a mock ViewModel
    Text("SessionFinishedView Preview - Requires ViewModel")
}
