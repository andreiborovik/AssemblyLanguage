.model small
.stack 100h
.data 

pathInput db 200 dup(?)
pathOutput db 200 dup(?)
commandLine db 127 dup (?)
buf db 2000 dup (?)
lenBuf equ 2000
inputFile dw ?
outputFile dw ? 
modeRead equ 00h
modeWrite equ 01h
slovo db 50, ? , 50 dup(?)
i dw 0
count dw 0
countW dw 0
flag db 0
prevLen dw 0  
startPosition dw 0
ERROR db 'Error!!!', '$', 0Dh, 0Ah
OpenFile02 db 'Error number 02h$'
OpenFile03 db 'Error number 03h$'
OpenFile04 db 'Error number 04h$'
OpenFile05 db 'Error number 05h$'
OpenFile0C db 'Error number 0Ch$'
.code
openFile macro path, mode, handle
    mov ah, 3Dh
    mov al, mode
    mov dx, offset path
    int 21h
    mov handle, ax 
endm

inputWord macro word
    mov ah, 0Ah
    mov dx, offset word
    int 21h
endm 

ErrorOpen:
cmp ax, 02h
jne @1
mov ah, 09h
mov dx, offset OpenFile02
int 21h
jmp next
@1:
cmp ax, 03h
jne @2
mov ah, 09h
mov dx, offset OpenFile03
int 21h
jmp next
@2:
cmp ax, 04h
jne @3
mov ah, 09h
mov dx, offset OpenFile04
int 21h
jmp next
@3:
cmp ax, 05h
jne @4
mov ah, 09h
mov dx, offset OpenFile05
int 21h
jmp next
@4:
mov ah, 09h
mov dx, offset OpenFile0C
int 21h
jmp next

ERRORCommandLine:
mov ah, 09h
mov dx, offset ERROR
int 21h
jmp next

main:
mov ax, @data 
mov es, ax
xor cx, cx
mov cl, ds:[80h]
cmp cl, 0
je ERRORCommandLine
mov si, 81h
mov di, offset commandLine
rep movsb 
mov ds, ax
mov si, offset commandLine

SkipSpace:
cmp byte ptr[si], ' '
jne File1
cmp byte ptr[si], 0
je ERRORCommandLine
inc si
jmp SkipSpace 
File1:
mov di, offset pathInput

pathFile1:
mov al, [si]
mov [di], al
inc si
inc di
cmp byte ptr[si], '.'
jne pathFile1

readTXT:
cmp byte ptr[si], '.'
je continueSearch1
jmp ERRORCommandLine
continueSearch1:
mov byte ptr[di], '.'
inc si
inc di
cmp byte ptr[si], 't'
je continueSearch2
jmp ERRORCommandLine
continueSearch2:
mov byte ptr[di], 't'
inc si
inc di
cmp byte ptr[si], 'x'
je continueSearch3
jmp ERRORCommandLine
continueSearch3:
mov byte ptr[di], 'x'
inc si
inc di 
cmp byte ptr[si], 't'
je continueSearch4
jmp ERRORCommandLine
continueSearch4:
mov byte ptr[di], 't'
inc si
inc di
endPathFile1:
mov byte ptr[di], 0

SkipSpace1:
cmp byte ptr[si], ' '
jne File2
inc si
jmp SkipSpace1
File2: 
mov di, offset pathOutput

pathFile2:
cmp byte ptr[si], 0
jne continueSearch5
jmp ERRORCommandLine
continueSearch5:
mov al, [si]
mov [di], al
inc si
inc di
cmp byte ptr[si], '.'
jne pathFile2

readTXT1:
cmp byte ptr[si], '.'
je continueSearch6
jmp ERRORCommandLine
continueSearch6:
mov byte ptr[di], '.'
inc si
inc di
cmp byte ptr[si], 't'
je continueSearch7
jmp ERRORCommandLine
continueSearch7:
mov byte ptr[di], 't'
inc si
inc di
cmp byte ptr[si], 'x'
je continueSearch8
jmp ERRORCommandLine
continueSearch8:
mov byte ptr[di], 'x'
inc si
inc di 
cmp byte ptr[si], 't'
je continueSearch9
jmp ERRORCommandLine
continueSearch9:
mov byte ptr[di], 't'
inc si
inc di
endPathFile2:
mov byte ptr[di], 0

SkipSpace2:
cmp byte ptr[si], ' '
jne installWord
inc si
jmp SkipSpace2
installWord: 
mov di, offset slovo

readWord:
add di, 2
mov al, [si]
mov [di], al
inc si
inc di
add slovo[1], 1

continueRead:
cmp byte ptr[si], ' '
je openFiles
cmp byte ptr[si], 0
je openFiles
mov al, [si]
mov [di], al
inc si
inc di
add slovo[1], 1
jmp continueRead


openFiles:
openFile pathInput, modeRead, inputFile
jc NoOpen
jmp two
NoOpen:
jmp ErrorOpen
two:
openFile pathOutput, modeWrite, outputFile
jc NoOpen
jmp readString

readString:
xor ax, ax
mov ah, 3Fh
mov bx, inputFile
mov cx, lenBuf
mov dx, offset buf
int 21h
cmp ax, 00h
jne resetFlags
jmp closeFiles
resetFlags:
mov i, 0
mov count, 0
mov countW, 0
findString:
mov cx, lenBuf
sub cx, i
mov al, 0Dh
mov di, offset buf
add di, i
mov bx, i
mov startPosition, bx
mov bx, cx
cmp cx, 0
je readString
repne scasb
je con
jmp StringWithout0D
con:
sub bx, cx
mov count, bx

mov al, 0Ah
mov cx, 1
repne scasb
je con1
jne tut
con1:
inc count
mov cx, count
mov countW, cx
tut:
cmp flag, 1
jne CMPFlag
jmp checkRightPart
CMPFlag:
cmp flag, 2
jne CMPLenght
jmp NoWriteRightPart

CMPLenght:
xor cx, cx
mov cl, slovo+1
cmp count, cx
jl writeSmallString

findWord:
mov di, offset buf
add di, i
mov si, offset slovo+2
xor cx, cx
mov cl, slovo+1
repe cmpsb
jcxz NoWrite  

findSpace:
mov al, ' '
mov di, offset buf
add di, i
mov cx, count
repne scasb
mov bx, count
sub bx, cx
add i, bx
mov count, cx
cmp count, 0
jne findWord
je writeToFile

writeSmallString:
mov ax, count
add i, ax
writeToFile:
mov dx, offset buf
add dx, startPosition
mov cx, countW 
xor ax, ax
mov ah, 40h
mov bx, outputFile
int 21h
suda:;add i, ax  
jmp findString 

NoWrite:
cmp byte ptr[di], '.'
je NoThisStirng
cmp byte ptr[di], ','
je NoThisStirng
cmp byte ptr[di], '?'
je NoThisStirng
cmp byte ptr[di], '!'
je NoThisStirng
cmp byte ptr[di], ' '
jne findSpace
NoThisStirng:
cmp flag, 1
jne next1
mov flag, 2
mov prevLen, 0
next1:
mov ax, count
add i, ax
mov count, 0
mov countW, 0
cmp prevLen, 0
jg deleteString
jmp findString
 
NoWriteRightPart:
mov ax, count
add i, ax
mov count, 0
mov countW, 0
mov prevLen, 0
mov flag, 0
jmp findString 
 
StringWithout0D:
sub bx, cx
mov count, bx
mov countW, bx
mov prevlen, bx
mov flag, 1
jmp CMPLenght 

checkRightPart:
mov flag, 0
jmp CMPLenght

deleteString:
mov ah, 42h
mov bx, outputFile
xor cx, cx
mov cx, 0ffffh
mov al, 1
mov dx, prevLen
not dx
inc dx
return:
int 21h
mov prevLen, 0 
xor ax, ax
mov bx, outputFile
xor cx, cx
mov ah, 40h
int 21h
jmp findString

closeFiles:
mov ah, 3Eh
mov bx, inputFile
int 21h
mov ah, 3Eh
mov bx, outputFile
int 21h
next:
mov ax, 4C00h
int 21h
end main