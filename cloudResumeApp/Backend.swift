import Amplify
import UIKit
import AWSCognitoAuthPlugin

class Backend {
    static let shared = Backend()

    private init() {
        // Initialize Amplify
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Initialized Amplify")
        } catch {
            print("Could not initialize Amplify: \(error)")
        }

        // Listen to authentication events within an asynchronous Task
        Task {
            do {
                _ = try await Amplify.Hub.listen(to: .auth) { [weak self] event in
                    self?.handleAuthEvent(event)
                }
            } catch {
                print("Error setting up Amplify.Hub.listen: \(error)")
            }
        }
    }

    // Define the handleAuthEvent method within the Backend class
    private func handleAuthEvent(_ event: HubPayload) {
        // Handle authentication events here
        switch event.eventName {
        case HubPayload.EventName.Auth.signedIn:
            print("==HUB== User signed In, update UI")
            self.updateUserData(withSignInStatus: true)
        case HubPayload.EventName.Auth.signedOut:
            print("==HUB== User signed Out, update UI")
            self.updateUserData(withSignInStatus: false)
        case HubPayload.EventName.Auth.sessionExpired:
            print("==HUB== Session expired, show sign in UI")
            self.updateUserData(withSignInStatus: false)
        default:
            // Handle any other events or just ignore them
            break
        }
    }

    // Define the updateUserData method within the Backend class
    private func updateUserData(withSignInStatus status: Bool) {
        // Implement your logic to update user data and UI here
    }

    // Sign in
    func signIn() async {
        do {
            let signInResult = try await Amplify.Auth.signInWithWebUI(presentationAnchor: UIApplication.shared.windows.first!)
            if signInResult.isSignedIn {
                print("Sign in succeeded")
            }
        } catch let error as AuthError {
            print("Sign in failed \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }

    // Sign out
    func signOut() async {
        do {
            let result = try await Amplify.Auth.signOut()
            guard let signOutResult = result as? AWSCognitoSignOutResult else {
                print("Signout failed")
                return
            }

            switch signOutResult {
            case .complete:
                print("Successfully signed out")
            case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
                if let hostedUIError = hostedUIError {
                    print("HostedUI error: \(hostedUIError)")
                }
                if let globalSignOutError = globalSignOutError {
                    print("GlobalSignOut error: \(globalSignOutError)")
                }
                if let revokeTokenError = revokeTokenError {
                    print("Revoke token error: \(revokeTokenError)")
                }
            case .failed(let error):
                print("SignOut failed with \(error)")
            }
            } catch {
                print("SignOut failed with error: \(error)")
            }
        }

    // Change the user's internal state, triggering a UI update on the main thread
    func updateUserData(withSignInStatus status: Bool) async {
       await MainActor.run {
            let userData: UserData = .shared
            userData.isSignedIn = status
        }
    }
}
