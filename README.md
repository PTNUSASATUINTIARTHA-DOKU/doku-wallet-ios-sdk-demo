# Doku Wallet SDK Demo Project

This demo project demonstrates the integration and usage of the Doku Wallet SDK in a Swift application, utilizing the VIPER architecture. 

## SPM Integrated
The SDK has been pre-integrated using Swift Package Manager, so no additional setup for the SDK is required.

## Configure Credentials
The SDK requires credentials for use. Fill the Credential.swift file to try the demo project app.

## Understanding the Project Structure

The project adheres to the VIPER architecture, which organizes the codebase into distinct modules, each centered around a specific feature set of Doku Wallet SDK.

### Key Components
View: Display the UI elements.

Interactor: Handle the business logic defined by the use cases.

Presenter: Prepare data for presentation and coordinate the view with the interactor.

Entity: Represent the core data models used across the project.

Router: Manage the navigation logic, outlining the sequence of screens.

### Utilizing the SDK
To grasp how the SDK is integrated and utilized within this project, inspect the Interactor files across the different modules. These files provide insights into how Doku Wallet SDK is employed to accomplish various tasks and functionalities.
