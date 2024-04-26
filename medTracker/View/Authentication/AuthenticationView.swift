//
//  Bienvenida.swift
//  medTracker
//
//  Created by Alumno on 09/11/23.
//

import SwiftUI

/**********************
 This view only displays a welcome message and two buttons to log in or register.
 **********************************/
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Variable in charge of handling sign in and register
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("mainWhite")
                    .ignoresSafeArea()
                VStack{
                    // Show the logo
                    if colorScheme == .light {
                        Image("logoV")
                            .resizable()
                            .imageScale(.small)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                    }
                    else{
                        Image("logoDarkMode")
                            .resizable()
                            .imageScale(.small)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                    }
                    // Buttons to log in or to create a new account
                    NavigationLink {
                        LogInView(signInModel: authViewModel.makeSignInViewModel())
                    } label: {
                        Text("Iniciar Sesión")
                            .gradientStyle() // apply gradient style
                    }
                    
                    NavigationLink {
                        RegisterView(createAccountModel: authViewModel.makeCreateAccountViewModel())
                    } label: {
                        Text("Registrarse")
                            .gradientStyle() // apply gradient style
                    }
                    
                }
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        AuthenticationView()
            .environmentObject(AuthViewModel())
    }
}
