import SwiftUI

/**********************
 This view submits a request to firebase to create a new user. The view first gets the name, email, and password and then makes the request.
 **********************************/

struct RegisterView: View {
    @StateObject var createAccountModel: AuthViewModel.CreateAccountViewModel
    @State private var showErrorAlert = false
    @State private var selectedAccountType = ["Paciente", "Doctor"]
    @State private var emptyField = false
    @State var user = User()
    @State var passwordConfirm = ""
    
    @State var errorMessage = ""
    
    var body: some View {
            Form {
                // Group that contains main data to enter
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
                    SecureField("Confirmar Contraseña", text: $passwordConfirm)
                        .textContentType(.password)
                }
                .padding()
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.mainBlue, lineWidth: 1)
                )
                
                // Account Type Picker
                Picker("Account Type", selection: $createAccountModel.role) {
                    ForEach(selectedAccountType, id: \.self) { type in
                        Text(type).tag(type)
                    }   
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 10)
                Section {
                    Button(action: {
                        if createAccountModel.name.isEmpty || createAccountModel.email.isEmpty || createAccountModel.password.isEmpty  {
                            showErrorAlert = true
                            errorMessage = "Llena todos los valores"
                        } else if passwordConfirm != createAccountModel.password {
                            showErrorAlert = true
                            errorMessage = "Las contraseñas no coinciden"
                        }
                        else {
                            createAccountModel.submit() //Submits the request to firebase to create a new user.
                        }
                    }, label: {
                        // Use changingText to show a progressView when the request is loading
                        ChangingText(state: $createAccountModel.state, title: "Crear Cuenta")
                    })
                    .gradientTextStyle() // apply gradient style
                }
            }
            .keyboardToolbar() // apply the button to have an ok and dismiss the view
            .onSubmit(createAccountModel.submit)
             // The alert and onReceive check when there is a registrationError and show it.
            .onReceive(createAccountModel.$error) { registrationMessage in
                if registrationMessage != nil {
                    showErrorAlert = true
                    if let message = registrationMessage?.localizedDescription {
                        if message.contains("email address is already"){
                            errorMessage = "El email ingresado ya esta en uso"
                        } else if message.contains("email address"){
                            errorMessage = "El email ingresado no es válido"
                        } else if message.contains("password must be 6 characters") {
                            errorMessage = "La contraseña debe tener al menos seis caracteres"
                        } else {
                            errorMessage = "Error, no se pudo crear la cuenta."
                        }
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(
                    title: Text("Error al Crear la Cuenta"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"), action: {
                        // Reset the registrationErrorMessage to nil when dismissing the alert
                        createAccountModel.error = nil
                    })
                )
            }
            .navigationTitle("Registrarse")
            
        }
}

struct registroUsuario_Previews: PreviewProvider {
    static var viewModels = AuthViewModel()
    static var previews: some View {
        RegisterView(createAccountModel: viewModels.makeCreateAccountViewModel())
    }
}

