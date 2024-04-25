import SwiftUI

/**********************
 This view sends the request to firebase to log in and show any errors as alerts.
 **********************************/
struct LogInView: View {
    // Object that makes the submission to firebase
    @StateObject var signInModel: AuthViewModel.SignInViewModel
    
    var body: some View {
            Form {
                // Group that contains the data to be filled by the user with modifiers that tell the type of data that user will enter and what kind of modifications this data has
                Group {
                    TextField("Email", text: $signInModel.email)
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    SecureField("Contraseña", text: $signInModel.password)
                        .textContentType(.password)
                }
                // Groupped style to be applied to the inputs
                .inputStyle()
                
                
                Section {
                    Button(action: {
                        signInModel.submit()
                    }, label: {
                        // Use changingText to show a progressView when the request is loading
                        ChangingText(state: $signInModel.state, title: "Iniciar Sesión")
                    })
                    .gradientStyle() // apply gradient style
                }
                
            }
            .keyboardToolbar()
            .onSubmit(signInModel.submit)
            .alert("Error al iniciar sesión", error: $signInModel.error) // Show the error if there is any with the submission
            .navigationTitle("Iniciar Sesión")
        }
}

#Preview {
    NavigationStack {
        RegisterView(createAccountModel: AuthViewModel().makeCreateAccountViewModel())
    }
}




