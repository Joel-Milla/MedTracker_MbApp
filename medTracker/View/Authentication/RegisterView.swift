import SwiftUI

/**********************
 This view submits a request to firebase to create a new user. The view first gets the name, email, and password and then makes the request.
 **********************************/

struct RegisterView: View {
    // Variabl to display information to the user
    @State private var typesOfAccount = ["Paciente", "Doctor"]
    // Object that makes the submission
    @StateObject var createAccountModel: AuthViewModel.CreateAccountViewModel
    @State private var showErrorAlert = false
    
    var body: some View {
            Form {
                // Group that contains the data to be filled by the user with modifiers that tell the type of data that user will enter and what kind of modifications this data has
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
                // Groupped style to be applied to the inputs
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
//                        if verifyPassword(password: createAccountModel.password) {
                            createAccountModel.submit()
//                        } else {
//                            showErrorAlert = true
//                        }
                    }, label: {
                        // Use changingText to show a progressView when the request is loading
                        ChangingText(state: $createAccountModel.state, title: "Crear Cuenta")
                    })
                    .gradientStyle() // apply gradient style
                    .alert(isPresented: $showErrorAlert) {
                        Alert(title: Text("Error"), message: Text("La contraseña debe tener al menos 8 caracteres, una mayúscula y un carácter especial."), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .onSubmit(createAccountModel.submit)
            .alert("Error al registrarse", error: $createAccountModel.error) // Show the error if there is any with the submission
            .navigationTitle("Registrarse")
            
        }
    // function to verify if the password is safe
    func verifyPassword(password: String) -> Bool {
        // Verificar si la contraseña tiene más de 8 caracteres
        guard password.count >= 8 else {
            return false
        }
        
        // Verificar si la contraseña contiene al menos una mayúscula
        let uppercaseLetters = CharacterSet.uppercaseLetters
        guard password.rangeOfCharacter(from: uppercaseLetters) != nil else {
            return false
        }
        
        // Verificar si la contraseña contiene al menos un carácter especial
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()-_=+[]{}|;:'\",.<>?")
        guard password.rangeOfCharacter(from: specialCharacters) != nil else {
            return false
        }
        
        // Si cumple todas las condiciones, la contraseña es válida
        return true
    }}



#Preview {
    NavigationStack {
        RegisterView(createAccountModel: AuthViewModel().makeCreateAccountViewModel())
    }
}

