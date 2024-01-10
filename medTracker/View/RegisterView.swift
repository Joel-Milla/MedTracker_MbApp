import SwiftUI

/**********************
 This view submits a request to firebase to create a new user. The view first gets the name, email, and password and then makes the request.
 **********************************/

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var authentication: AuthViewModel.CreateAccountViewModel
    @State private var showAlert = false
    @State private var selectedAccountType = ["Paciente", "Doctor"]
    @State private var seleccion = "Paciente"
    @State private var emptyField = false
    @State var user = User()
    @State var passwordConfirm = ""
    
    @State var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre completo", text: $authentication.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("mainBlue"), lineWidth: 1)
                    )
                
                Group {
                    TextField("Email", text: $authentication.email)
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("Contraseña", text: $authentication.password)
                        .textContentType(.password)
                    SecureField("Confirmar Contraseña", text: $passwordConfirm)
                        .textContentType(.password)
                }
                .padding()
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("mainBlue"), lineWidth: 1)
                )
                
                // Account Type Picker
                Picker("Account Type", selection: $seleccion) {
                    ForEach(selectedAccountType, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                Button(action: {
                    if authentication.name.isEmpty || authentication.email.isEmpty || authentication.password.isEmpty  {
                        authViewModel.registrationErrorMessage = "Fill all the values"
                    } else if passwordConfirm != authentication.password {
                        showAlert = true
                        errorMessage = "Las contraseñas no coinciden"
                    }
                    else {
                        authentication.role = seleccion
                        authentication.submit() //Submits the request to firebase to create a new user.
                        authViewModel.email = authentication.email // set the email of the current user.
                        authViewModel.userRole = seleccion
                        user.nombreCompleto = authentication.name
                        HelperFunctions.write(user, inPath: "User.JSON")
                        HelperFunctions.write(seleccion, inPath: "role.JSON")
                    }
                }, label: {
                    // The switch check the status of the request and shows a loading animation if it is waiting a response from firebase.
                    switch authentication.state {
                    case .idle:
                        Text("Crear Cuenta")
                    case .isLoading:
                        ProgressView()
                    }
                })
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color("mainBlue"), Color("blueGreen")]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .keyboardToolbar()
            .onSubmit(authentication.submit)
            // The alert and onReceive check when there is a registrationError and show it.
            .onReceive(authViewModel.$registrationErrorMessage) { registrationMessage in
                if registrationMessage != nil {
                    showAlert = true
                    errorMessage = registrationMessage!
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error de Registro"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"), action: {
                        // Reset the registrationErrorMessage to nil when dismissing the alert
                        authViewModel.registrationErrorMessage = nil
                        errorMessage = ""
                    })
                )
            }
            .navigationTitle("Registrarse")
            
        }
    }
}

struct registroUsuario_Previews: PreviewProvider {
    static var viewModels = AuthViewModel()
    static var previews: some View {
        RegisterView(authentication: viewModels.makeCreateAccountViewModel())
    }
}

