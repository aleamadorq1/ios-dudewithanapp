//
//  PremiumInfoView.swift
//  DudeWithAnApp
//
//  Created by Alejandro on 6/28/23.
//

import Foundation
import SwiftUI

struct PremiumInfoView: View {
    @Binding var isPresented: Bool
    var body: some View {
        NavigationView {
            VStack {

                Text("Through our unique app, we spread the Word of God, bringing the word of God directly to your lock screen. This mission needs your support.")
                    .font(.body)
                    .padding()
                
                Button(action: {
                    // add your action for premium here
                }) {
                    Text("Try for free!")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
                Button(action: {
                    // add your action for patreon here
                }) {
                    Text("Become a Patreon")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                
                Text("For a single payment of $3.99, not only do you unlock Night Mode and bespoke widgets, but you join us in fulfilling our Christian duty of spreading the Word. Your contribution counts! With a small commitment of $20 a year, join our community of believers and supporters. You're helping keep the wisdom of the Bible accessible, fulfilling your duty to share God's Word. By helping the project you help us covering the costs since this project is totally supported by its Patreons.")
                    .padding()
                    .font(.body)

                Spacer()
                Button(action: {
                    // add your action for patreon here
                }) {
                    Text("Restore Purchases")
                        .foregroundColor(.white)
                        .padding(5)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Join Our Mission:")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "arrow.backward")
                    }
                }
            }
        }
    }
}
