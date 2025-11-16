# Requirements Document

## Introduction

This document specifies the requirements for integrating a trained Huawei ModelArts retina disease classification model into the EyeWise Connect diagnosis page. The system currently uses mock data for retinal analysis and needs to be updated to call the real ModelArts inference endpoint deployed in the ap-southeast-3 region. The integration must handle authentication, image preprocessing, API communication, response parsing, and error handling while maintaining the existing user experience.

## Glossary

- **ModelArts Service**: Huawei Cloud's AI model training and deployment platform that hosts the retina classification model
- **IAM Token**: Identity and Access Management authentication token obtained using AK/SK credentials for API authorization
- **Diagnosis Provider**: Flutter provider class that manages the state and logic for the diagnosis page
- **Retina Inference Service**: Service layer that communicates with the ModelArts endpoint
- **Backend Proxy**: Node.js server that handles ModelArts API calls for web platform to avoid CORS issues
- **Base64 Encoding**: Method of encoding binary image data as ASCII text for API transmission
- **AK/SK**: Access Key and Secret Key credentials for Huawei Cloud authentication
- **CORS**: Cross-Origin Resource Sharing, browser security mechanism that restricts API calls

## Requirements

### Requirement 1

**User Story:** As a healthcare provider, I want to analyze retinal images using the trained ModelArts model, so that I can receive accurate AI-powered diagnosis results for my patients.

#### Acceptance Criteria

1. WHEN THE user selects a retinal image and clicks analyze, THE Diagnosis Provider SHALL invoke THE Retina Inference Service with the image bytes
2. WHEN THE Retina Inference Service receives image bytes, THE Retina Inference Service SHALL encode the image as base64 and send it to THE ModelArts endpoint
3. WHEN THE ModelArts endpoint returns a successful response, THE Diagnosis Provider SHALL parse the classification results and display them to the user
4. WHEN THE ModelArts endpoint returns predictions, THE Diagnosis Provider SHALL extract the predicted class name and confidence score from the response
5. WHERE THE application runs on web platform, THE Backend Proxy SHALL handle all ModelArts API calls to avoid CORS restrictions

### Requirement 2

**User Story:** As a system administrator, I want the ModelArts credentials to be securely loaded from configuration files, so that sensitive authentication information is not hardcoded in the application.

#### Acceptance Criteria

1. THE Retina Inference Service SHALL load ModelArts configuration from env.json file containing project ID, access key, secret key, service ID, region, and invoke URL
2. WHEN THE configuration is missing or incomplete, THE Retina Inference Service SHALL throw a descriptive error message indicating which credentials are missing
3. THE application SHALL validate that all required ModelArts configuration fields are present before attempting inference
4. WHERE THE application runs on web platform, THE Backend Proxy SHALL receive credentials from the Flutter client for each request

### Requirement 3

**User Story:** As a developer, I want the system to handle ModelArts authentication automatically, so that API calls succeed without manual token management.

#### Acceptance Criteria

1. WHEN THE ModelArts endpoint returns a 401 unauthorized error, THE Huawei ModelArts Service SHALL obtain an IAM token using the AK/SK credentials
2. WHEN THE IAM token is obtained, THE Huawei ModelArts Service SHALL cache the token until 5 minutes before expiry
3. WHEN THE cached token is still valid, THE Huawei ModelArts Service SHALL reuse the token without requesting a new one
4. WHEN THE IAM token request fails, THE Huawei ModelArts Service SHALL throw an exception with the error details from the IAM service

### Requirement 4

**User Story:** As a healthcare provider, I want to see meaningful error messages when analysis fails, so that I can understand what went wrong and take appropriate action.

#### Acceptance Criteria

1. WHEN THE image size exceeds 8MB, THE Huawei ModelArts Service SHALL reject the image with a message instructing the user to compress or resize
2. WHEN THE ModelArts API returns an error response, THE Diagnosis Provider SHALL display the error message to the user
3. WHEN THE network request fails, THE Diagnosis Provider SHALL display a network error message to the user
4. WHEN THE ModelArts response format is unexpected, THE Retina Inference Service SHALL log the response structure and throw a descriptive parsing error

### Requirement 5

**User Story:** As a healthcare provider, I want the diagnosis results to include severity levels and recommendations, so that I can provide appropriate guidance to patients.

#### Acceptance Criteria

1. WHEN THE ModelArts model returns a predicted class, THE Diagnosis Provider SHALL map the class name to a severity level based on confidence score
2. WHEN THE predicted class is "Normal", THE Diagnosis Provider SHALL set severity to "Normal" regardless of confidence
3. WHEN THE confidence is 0.9 or higher, THE Diagnosis Provider SHALL set severity to "High"
4. WHEN THE confidence is between 0.8 and 0.9, THE Diagnosis Provider SHALL set severity to "Medium"
5. WHEN THE confidence is below 0.8, THE Diagnosis Provider SHALL set severity to "Low"
6. WHEN THE diagnosis is complete, THE Diagnosis Provider SHALL generate condition-specific recommendations based on the predicted class

### Requirement 6

**User Story:** As a developer, I want the ModelArts integration to support multiple request payload formats, so that the system works regardless of the model's expected input structure.

#### Acceptance Criteria

1. WHEN THE first inference attempt fails, THE Huawei ModelArts Service SHALL retry with an alternative payload format
2. THE Huawei ModelArts Service SHALL first attempt inference with payload format {"image": "<base64>"}
3. IF THE first format fails, THEN THE Huawei ModelArts Service SHALL retry with format {"instances": [{"image": "<base64>"}]}
4. WHEN both payload formats fail, THE Huawei ModelArts Service SHALL throw the error from the first attempt

### Requirement 7

**User Story:** As a healthcare provider, I want the system to integrate AI-powered second opinions from DeepSeek, so that I receive additional context and reasoning about the diagnosis.

#### Acceptance Criteria

1. WHEN THE ModelArts inference succeeds, THE Diagnosis Provider SHALL request a second opinion from THE AI Chat Service with the image and model probabilities
2. WHEN THE AI Chat Service returns a second opinion, THE Diagnosis Provider SHALL prepend it to the recommendations list
3. IF THE AI Chat Service fails or API key is missing, THEN THE Diagnosis Provider SHALL continue without the second opinion
4. THE Diagnosis Provider SHALL not block or fail the diagnosis if the second opinion request fails

### Requirement 8

**User Story:** As a system operator, I want comprehensive logging throughout the inference pipeline, so that I can troubleshoot issues and monitor system behavior.

#### Acceptance Criteria

1. THE Huawei ModelArts Service SHALL log the invoke URL and payload keys before each API call
2. THE Huawei ModelArts Service SHALL log the response status code and data type for each API response
3. WHEN THE system uses the backend proxy, THE Huawei ModelArts Service SHALL log that the proxy is being used
4. WHEN THE system obtains an IAM token, THE Huawei ModelArts Service SHALL log the authentication flow
5. THE Diagnosis Provider SHALL log when mock data is being used instead of real inference

### Requirement 9

**User Story:** As a developer, I want the backend proxy to handle ModelArts inference for web clients, so that CORS restrictions do not prevent API calls.

#### Acceptance Criteria

1. WHERE THE application runs on web platform, THE Huawei ModelArts Service SHALL send requests to http://localhost:3001/api/modelarts/infer
2. THE Backend Proxy SHALL receive the base64 image, service ID, region, access key, secret key, and project ID from the client
3. THE Backend Proxy SHALL construct the proper ModelArts API request with authentication headers
4. THE Backend Proxy SHALL return the ModelArts response to the Flutter client
5. WHEN THE Backend Proxy encounters an error, THE Backend Proxy SHALL return a structured error response with status code and error details

### Requirement 10

**User Story:** As a healthcare provider, I want the diagnosis page to remove mock data and use real ModelArts predictions, so that I receive accurate analysis results.

#### Acceptance Criteria

1. THE Diagnosis Provider SHALL remove the mock data generation code for retinal model analysis
2. THE Diagnosis Provider SHALL uncomment and activate the real ModelArts inference code path
3. WHEN THE user selects the retinal model, THE Diagnosis Provider SHALL call the Retina Inference Service with the selected image bytes
4. THE Diagnosis Provider SHALL remove the TODO comment about fixing ModelArts authentication
5. THE Diagnosis Provider SHALL remove the temporary delay that simulates processing time
