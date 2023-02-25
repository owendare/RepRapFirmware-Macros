; Array.g is a macro intended to be used by other macros to manage data in an array-like structure. 
; You call array.g once to create an array macro.  You call that macro add an element to the array, 
; read the value at a specified index, get the length of the array, or replace a value at an existing index. 
; This macro creates the array in a /temp sub-folder of the sys directory, but you can change the location if you want.
; Author: mikeabuilder

; One day, if RRF adds array support to the core RRF funstionality, this macro will no longer be needed.
; That will be a happy day. 

var Array_location = "0:/sys/temp/"
; Typical usage
;  M98 P"0:/sys/array.g" S"array name"

;Parameter definition and usage
;  S"array_name"  Required parameter. This is the name of an array you want to create. If you use a name that was used previously, the old array will be overwritten.

; PARAMETER CHECK
if !exists(param.S)
  M291 P"No macro name provided. Cancelling array build" S3 T-1
  M99

var file = var.Array_location^param.S^".g"  ;create full path to the new array
; The following lines are all echoed into the new array file
echo >{var.file}  "; This file was created by the macro array.g, normally located in the /sys directory."
echo >>{var.file} "; It is used as method for creating a rudimentary array data capability for other macros."
echo >>{var.file} "; This macro is called to add elements to the array, read values of an existing element,"
echo >>{var.file} "; change the values of existing element, or get the number of elements in the array."
echo >>{var.file} "; The requested data is passed back to the calling macro by putting it into a global "
echo >>{var.file} "; variable called gloabl.macro_response."
echo >>{var.file} "; Author: mikeabuilder"
echo >>{var.file} "; "
echo >>{var.file} "; TYPICAL USE"
echo >>{var.file} "; M98 P""0:/sys/temp/"^var.file^""" V""value""  I""index"" L                "
echo >>{var.file} "; "
echo >>{var.file} "; PARAMETERS"
echo >>{var.file} ";  V""value""   When used without the I parameter, the value is appended to that array as a new     "
echo >>{var.file} ";               element. The value of global.macro_response is set to the array index of the added  "
echo >>{var.file} ";               value.                                                                              "
echo >>{var.file} ";  I""number""  When used without the A parameter, the value of element I[number] is returned in    "
echo >>{var.file} ";             global.macro_response.                                                                "
echo >>{var.file} ";             When both A and I parameters are used, the existing value of the element I[number] is "
echo >>{var.file} ";             replaced. If there is no element I[number], a new element I[number] is created. It    "
echo >>{var.file} ";             might get overwritten.                                                                "
echo >>{var.file} ";  R""number"" When R is present the index of the item name is returned in global.array_response    "
echo >>{var.file} ";              if the item name is not found, then -1 is returned                                   "
echo >>{var.file} ";  None       If no parameter is present, the length of the array is returned in                    "
echo >>{var.file} ";             global.array_response.                                                                "
echo >>{var.file} "; "
echo >>{var.file} "; THEORY OF OPERATION"
echo >>{var.file} "; When array elemenmts are added or changed, they are added to the end of this macro file. Changed  "
echo >>{var.file} "; element values result is multiple values in this file. The valie closest to the end of the file is"
echo >>{var.file} "; the current value. This means that a value that is changed a lot will make the file longer and    "
echo >>{var.file} "; longer. Simple enough, eh? "
echo >>{var.file} ""
echo >>{var.file} ""
echo >>{var.file} ";START OF THE REAL WORK"
echo >>{var.file} ""
echo >>{var.file} "; If we are appending or replacing, this is the easy part"
echo >>{var.file} "; Set up some variables"
echo >>{var.file} "var index = 0                                                                                       "
echo >>{var.file} "var ThisValue = """"                                                                                "
echo >>{var.file} "if !exists(global.array_response)                                                                   "
echo >>{var.file} "  global array_response = var.index                                                                 "
echo >>{var.file} "else                                                                                                "
echo >>{var.file} "  set global.array_response = var.index                                                             "
echo >>{var.file} "var my_len = 0                                                                                      "
echo >>{var.file} {"var file = """^var.file^""""}
echo >>{var.file} ""
echo >>{var.file} "; If we are adding a new element or changing the value of an existing element it happens here.      "
echo >>{var.file} "if exists(param.V)          ; We are appending or changing                                          "
echo >>{var.file} "  if exists(param.I)        ; An index is supplied, so we are changing a value                      "
echo >>{var.file} "    M98 P"""^{var.file}^"""  ; query myself for the length of my array                              "
echo >>{var.file} "    if (param.I > global.array_response)"  ; check if the index is out of bound                     "
echo >>{var.file} "     set var.index = global.array_response  ; The array length is the next index                    "
echo >>{var.file} "    else                      ;    index is in bounds                                               "
echo >>{var.file} "     set var.index = param.I  ; The user supplied the index for the element to be replaced          "
echo >>{var.file} "  else                      ; We are adding a new element so we need to get the next unused index   "
echo >>{var.file} "    M98 P"""^{var.file}^"""  ; query myself for the length of my array                              "
echo >>{var.file} "    set var.index = global.array_response  ; The array length is the next index                     "
echo >>{var.file} "                                                                                                    "
echo >>{var.file} "  ; we have the index and the value to add, so lets add to our own file                             "
echo >>{var.file} "                                                                                                    "
echo >>{var.file} "  echo >>{var.file} ""       ;NEXT ARRAY ELEMENT""                                                  "
echo >>{var.file} "  echo >>{var.file} ""set var.ThisValue = """"""^param.V^""""""""                                   "                                                                
echo >>{var.file} "  echo >>{var.file} ""if exists(param.I)  ; we are returning an existing value""                    "
echo >>{var.file} "  echo >>{var.file} ""  if param.I = ""^var.index                                                   "
echo >>{var.file} "  echo >>{var.file} ""    set global.array_response = """"""^param.V^""""""""                         "
echo >>{var.file} "  echo >>{var.file} ""    M99""                                                                     "
echo >>{var.file} "  echo >>{var.file} ""if exists(param.R)  ; we are returning an index of a value""                  "                 
echo >>{var.file} "  echo >>{var.file} ""  if param.R = var.ThisValue""                                                " 
echo >>{var.file} "  echo >>{var.file} ""    set global.array_response = ""^var.index                                  "    
echo >>{var.file} "  echo >>{var.file} ""    M99""                                                                     "
echo >>{var.file} "  echo >>{var.file} ""  else""                                                                      "
echo >>{var.file} "  echo >>{var.file} ""    set global.array_response=-1""                                            " 
echo >>{var.file} "  echo >>{var.file} ""else""                                                                        "
echo >>{var.file} "  echo >>{var.file} ""  if !exists(param.I) &&  !exists(param.V)   &&  !exists(param.R)""           "
echo >>{var.file} "  echo >>{var.file} ""    set var.my_len = max(global.array_response,""^var.index+1^"")""           "
echo >>{var.file} "  echo >>{var.file} ""    set global.array_response= var.my_len""                                   "

echo >>{var.file} ";  "