import SwiftUI

/**********************
 This view sends the request to firebase to log in and show any errors as alerts.
 **********************************/
struct LogInView: View {
    @EnvironmentObject var authentication: AuthViewModel
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Group {
                    TextField("Email", text: $authentication.email)
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    SecureField("Contraseña", text: $authentication.password)
                        .textContentType(.password)
                }
                .padding()
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("mainBlue"), lineWidth: 1)
                )
                
                Button(action: {
                    authentication.signIn()
                }, label: {
                    // The switch check the status of the request and shows a loading animation if it is waiting a response from firebase.
                    switch authentication.state {
                    case .idle:
                        Text("Iniciar Sesión")
                    case .isLoading:
                        ProgressView()
                    }
                })
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                //.frame(width: UIScreen.main.bounds.width * 0.8, height: 50)
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color("mainBlue"), Color("blueGreen")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .shadow(radius: 5)
                
            }
            .keyboardToolbar()
            // The alert and onReceive check when there is a signIn error and show it.
            .onReceive(authentication.$signInErrorMessage) { newValue in
                showErrorAlert = newValue != nil
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error al ingresar"),
                    message: Text("El mail o la contraseña son incorrectos"),
                    dismissButton: .default(Text("OK"), action: {
                        // Reset the registrationErrorMessage to nil when dismissing the alert
                        authentication.signInErrorMessage = nil
                    })
                )
            }
            .navigationTitle("Iniciar Sesión")
        }
    }
}

struct loginView_Previews: PreviewProvider {
    static var temporary = AuthViewModel()
    static var previews: some View {
        LogInView()
    }
}



