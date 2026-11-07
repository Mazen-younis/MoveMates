//
//  ViewExtensions.swift
//  MoveMates
//
//  Created by Mazen Younis on 27/05/2025.
//

import SwiftUI
import Foundation

extension View {
    func screenTitleStyle() -> some View {
        self
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.pureWhite)
            .frame(maxWidth: .infinity, alignment: .center) 
            .padding(.top, 20)
            .padding(.bottom, 10)
    }
    
    
    func moveMatesButtonStyle() -> some View {
            self
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.aquaBlue, .charcoalGray]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
        }
}
