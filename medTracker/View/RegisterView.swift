import SwiftUI

/**********************
 This view submits a request to firebase to create a new user. The view first gets the name, email, and password and then makes the request.
 **********************************/

struct RegisterView: View {
    // Variables to display information to the user
    @State private var typesOfAccount = ["Paciente", "Doctor"]
    // Object that makes the submission
    @StateObject var createAccountModel: AuthViewModel.CreateAccountViewModel
    
    var body: some View {
            Form {
                // Group that contains the data to be filled by the user
                Group {
                    TextField("Nombre completo", text: $createAccountModel.name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("Email", text: $createAccountModel.email)
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Contraseña", text: $createAccountModel.password)
                        .textContentType(.password)
                    SecureField("Confirmar Contraseña", text: $createAccountModel.confirmPassword)
                        .textContentType(.password)
                }
                // Groupped style to be applied to the input
                .inputStyle()
                
                // Account Type Picker
                Picker("Account Type", selection: $createAccountModel.role) {
                    ForEach(typesOfAccount, id: \.self) { type in
                        Text(type).tag(type)
                    }   
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 10)
    
                Section {
                    Button(action: {
                        createAccountModel.submit() //Submits the request to firebase to create a new user.
                    }, label: {
                        // Use changingText to show a progressView when the request is loading
                        ChangingText(state: $createAccountModel.state, title: "Crear Cuenta")
                    })
                    .gradientStyle() // apply gradient style
                }
            }
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .onSubmit(createAccountModel.submit)
            .alert("Error al guardar datos", error: $createAccountModel.error) // Show the error if there is any with the submission
            .navigationTitle("Registrarse")
            
        }
}

#Preview {
    NavigationStack {
        RegisterView(createAccountModel: AuthViewModel().makeCreateAccountViewModel())
    }
}

