//
//  ContentView.swift
//  Android Dev Assistant
//
//  Created by Chong Wen Hao on 31/1/26.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var adbHelper: ADBHelper = ADBHelper.shared
    
    var body: some View {
        VStack {
            
        }.padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                adbHelper.initialize()
            }
    }
}
