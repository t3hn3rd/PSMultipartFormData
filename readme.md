# 📄 PSMultipartFormData

## 🌍 Overview

**PSMultiPartFormData** is a PowerShell module that provides functionality for constructing and managing multipart form data for HTTP requests. This module helps in adding fields, files, and JSON objects to a form data body.

## ✨ Features
- Create Multipart Form Data: Easily create and manage multipart form data for HTTP requests.
- Add Form Fields: Add standard form fields (e.g., text fields) to the form data with the AddField method.
- Add Files: Add files to the form data using either file content or by specifying a file path. The AddFile method automatically detects the MIME type of the file.
- Add JSON-encoded Objects: Add complex objects as JSON-encoded fields to the form data with the AddObject method.
- Automatic MIME Type Detection: Integrates with the PSMimeTypes module to automatically determine the MIME type of files based on their extension or filename.
- Generate Unique Boundaries: Automatically generates a unique boundary for each multipart form data instance to separate the different parts.
- Generate Multipart Form Data Body: The GetBody method generates the full multipart form data body, ready for use in HTTP requests.
- Get Boundary: The GetBoundary method allows retrieval of the unique boundary used in the multipart form data.
- Reusable Multipart Form Data Objects: You can instantiate new MultiPartFormData objects easily using the New-MultipartFormData function.
- File Import: The Import-FileAsMultipartFormData function allows you to directly import a file from a specified path and add it to the multipart form data.

## 🔧 Installation

To use **PSMultiPartFormData**, import the module into your PowerShell session:

```powershell
Install-Module "PSMultipartFormData"
Import-Module "PSMultipartFormData"
```

## 📌 Functions & Usage

### 📟 Create a new MultipartFormData object
```powershell
$formData = New-MultipartFormData
$formData.GetBody()
$formData.GetBoundary()
```

### 📂 Create a new MultipartFormData object from a file
```powershell
$formData = Import-FileAsMultipartFormData -FilePath "C:\path\to\file.txt"
$formData.GetBody()
$formData.GetBoundary()
```

### ➕ Add fields to a MiltipartFormData object
```powershell
$formData = New-MultipartFormData
$formData.addField('test', 'testificate')
$formData.GetBody()
$formData.GetBoundary()
```

### ⚙️ Using the MultipartFormData object in an API request
```powershell
$requestURI = "https://my.example.api/api/v1/endpoint"
$formData = (New-MultipartFormData).
            addField('name', 'John Doe').
            addField('age', '55').
            addFile('C:\users\john\myfile.pdf')
$request = Invoke-RestMethod -Method Post -Uri $RequestURI -Body $formData.GetBody() -ContentType "multipart/form-data; charset=iso-8859-1; boundary=`"$($formData.GetBoundary())`""
```

## 📦 Dependencies
This module relies on:
- [PSMimeTypes](https://github.com/t3hn3rd/PSMimeTypes), A PowerShell module that provides functionality for resolving MIME types from file extensions and filenames. ([PSGallery](https://www.powershellgallery.com/packages/PSMimeTypes/))

## 🤝 Contributions
Contributions are welcome! If you'd like to improve this module, feel free to submit a pull request or open an issue.

## 📜 License
This project is licensed under the Apache 2.0 License. See the LICENSE file for details.

## 👨‍💻 Contributors
- **Kieron Morris** (t3hn3rd) - [kjm@kieronmorris.me](mailto:kjm@kieronmorris.me)

