# Speech-To-Text

## Feature
This is a sample that uses the start and stop recording buttons to convert your speech to text.

## Requirements
- Xcode 9 with Swift 4
- Deployment target is iOS 11.2+

## How it works
- Apple's 'Speech' framework was used to create this sample project. 'SFSpeechRecognizer' is used to ask the user for permission. 

- The audio from the device microphone is acquired using 'SFSpeechAudioBufferRecognitionRequest'. 

- `recognitionTask` API is used to perform and deliver the voice recognition request. The result is converted to String data type using `formattedString` and displayed in the text view.
