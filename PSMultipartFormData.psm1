<#
  .SYNOPSIS
      MultiPartFormData - A PowerShell module for creating and handling multipart form data for HTTP/REST requests.

  .DESCRIPTION
      A module to provide functionality for creating multipart form data used in HTTP requests, including adding form fields, files, and objects. It supports the conversion of file names to MIME types and encoding file content.

  .EXPORTS
      - Import-FileAsMultipartFormData
      - New-MultipartFormData

  .FUNCTIONS
      - Import-FileAsMultipartFormData
          Imports a file and returns a MultiPartFormData object with the file encoded as part of the form data.

          PARAMETERS:
              - FilePath (String, Mandatory): The path of the file to be added.

      - New-MultipartFormData
          Creates a new instance of the MultiPartFormData class.

          PARAMETERS:
              - None

  .EXAMPLE
      Creating and using multipart form data:
          $formData = New-MultipartFormData
          $formData.AddField("name", "John Doe")
          $formData.AddFile("file", "example.txt", "text/plain", "File content here")
          $formData.GetBody()
          # Output: The complete multipart form data body

  .EXAMPLE
      Importing a file as multipart form data:
          $multipart = Import-FileAsMultipartFormData -FilePath "C:\example.txt"
          $multipart.GetBody()
          # Output: Multipart form data body with the file included

  .NOTES
      Author: Kieron Morris/t3hn3rd (kjm@kieronmorris.me)
      Created: 2025-03-12
      Version: 1.0.1
      License: Apache License 2.0
      Contributors:
        - Kieron Morris/t3hn3rd
      Dependencies:
        - PSMimeTypes
      License: Apache License 2.0

  .LINK
      Github: https://github.com/t3hn3rd/PSMultipartFormData
#>

Import-Module "PSMimeTypes"

<#
.SYNOPSIS
    MultiPartFormData - A class for constructing and managing multipart form data for HTTP requests.

.DESCRIPTION
    The `MultiPartFormData` class provides methods for adding form fields, files, and objects to a multipart form data body. It supports generating a unique boundary for each instance, and encoding files as part of the form data.

.PROPERTIES
    - bodyLines (PSObject[]): Stores the lines of the multipart form data body.
    - boundary (string): A unique boundary used to separate parts in the multipart form data.
    - LF (string): The line feed characters used in the form data.

.METHODS
    - AddField (string, string): Adds a form field with the specified name and value to the body.
    - AddFile (string, string, string, PSObject): Adds a file with the specified name, filename, MIME type, and content.
    - AddFile (string): Adds a file from the provided file path to the form data.
    - AddObject (string, PSObject): Adds a PowerShell object as a JSON-encoded field to the form data.
    - GetBody (): Returns the complete multipart form data body as a string.
    - GetBoundary (): Returns the unique boundary for the multipart form data.

.EXAMPLE
    Add form fields and files to multipart form data
      $formData = [MultiPartFormData]::new()
      $formData.AddField("name", "John Doe")
      $formData.AddFile("file", "example.txt", "text/plain", "File content here")
      $formData.GetBody()

.EXAMPLE
    Add a file from a path
      $formData.AddFile("C:\path\to\file.txt")
      $formData.GetBody()

.EXAMPLE
    Add an object as a JSON field
      $obj = [PSCustomObject]@{ key = "value" }
      $formData.AddObject("jsonField", $obj)
      $formData.GetBody()

#>
class MultiPartFormData {
  hidden [PSObject[]]$bodyLines
  hidden [string]$boundary
  hidden [string]$LF
  MultiPartFormData() {
    $this.bodyLines = @()
    $this.boundary = [System.Guid]::NewGuid().ToString()
    $this.LF = "`r`n"
  }
  [MultiPartFormData] AddField([string]$name, [string]$value) {
    if($value) {
      $this.bodyLines += "--$($this.boundary)"
      $this.bodyLines += "Content-Disposition: form-data; name=`"$name`"" + $this.LF
      $this.bodyLines += "$value"
    }
    return $this
  }
  [MultiPartFormData] AddFile([string]$name, [string]$filename, [string]$mime, [PSObject]$fileContent) {
    $this.bodyLines += "--$($this.boundary)"
    $this.bodyLines += "Content-Disposition: form-data; name=`"$name`"; filename=`"$filename`""
    $this.bodyLines += "Content-Type: $mime" + $this.LF
    $this.bodyLines += $fileContent
    return $this
  }
  [MultiPartFormData] AddFile([string]$FilePath) {
    if($FilePath) {
      $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
      $fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)
      $Filename = Split-Path $FilePath -Leaf
      $MIME = Convert-FileNameToMimeType -FileName $Filename
      $this.AddFile('file', $Filename, $MIME, $fileEnc)
    }
    return $this
  }
  [MultiPartFormData] AddObject([string]$name, [PSObject]$object) {
    if($Object) {
      $this.AddField($name, ($object | ConvertTo-Json -Depth 100 -Compress))
    }
    return $this
  }
  [string] GetBody() {
    if ($this.bodyLines.Count -eq 0) {
      return ""
    }
    return ($this.bodyLines -join $this.LF) + $this.LF + "--$($this.boundary)--$($this.LF)"
  }
  [string] GetBoundary() {
    return $this.boundary
  }
}

<#
.SYNOPSIS
    Imports a file as part of a multipart form data object.

.DESCRIPTION
    The `Import-FileAsMultipartFormData` function reads a file from the specified path, converts it to a byte array, encodes it in ISO-8859-1,
    determines its MIME type based on the file extension, and adds it to a `MultiPartFormData` object.

.INPUTS
    - FilePath (String, Mandatory): The path to the file that will be imported into the multipart form data.

.OUTPUTS
    [MultiPartFormData] - A `MultiPartFormData` object with the file added as part of the form data.

.EXAMPLE
    Import a file as multipart form data
      multipartFormData = Import-FileAsMultipartFormData -FilePath "C:\example.txt"
      multipartFormData.GetBody()
#>
Function Import-FileAsMultipartFormData {
  param (
    [string]$FilePath
  )
  $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
  $fileEnc = [System.Text.Encoding]::GetEncoding('ISO-8859-1').GetString($fileBytes)
  $Filename = Split-Path $FilePath -Leaf
  $MIME = Convert-FileNameToMimeType -FileName $Filename
  $MPFD = [MultiPartFormData]::new()
  return $MPFD.AddFile('file', $Filename, $MIME, $fileEnc)
}

<#
.SYNOPSIS
    Creates a new instance of the `MultiPartFormData` class.

.DESCRIPTION
    The `New-MultipartFormData` function instantiates a new `MultiPartFormData` object, which can be used to build multipart form data for HTTP requests.
    This object allows for adding fields, files, and objects to the form data.

.OUTPUTS
    [MultiPartFormData] - A new instance of the `MultiPartFormData` class.

.EXAMPLE
    Create a new multipart form data object
      $multipartFormData = New-MultipartFormData
      $multipartFormData.AddField("name", "John Doe")
      $multipartFormData.GetBody()
#>
function New-MultipartFormData {
  return [MultiPartFormData]::new()
}

Export-ModuleMember -Function Import-FileAsMultipartFormData, New-MultipartFormData