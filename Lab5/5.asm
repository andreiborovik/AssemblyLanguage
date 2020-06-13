.model small
.stack 100h
.data   

file db 200 dup (?)
file2 db 200 dup (?)
file1 db 200 dup (?)  
size db ?  
flagBeginFile db 0
buf db 50 dup (?)
handler1 dw 0
handler2 dw 0
slovo db 50,?,50 dup (?)
errorMessage db "error$",0Dh,0Ah
OpenFile02 db 'Error number 02h$'
OpenFile03 db 'Error number 03h$'
OpenFile04 db 'Error number 04h$'
OpenFile05 db 'Error number 05h$'
OpenFile0C db 'Error number 0Ch$'
.code

ErrorOpen:
cmp ax, 02h
jne @1
mov ah, 09h
mov dx, offset OpenFile02
int 21h
jmp exitFromProgramm 
@1:
cmp ax, 03h
jne @2
mov ah, 09h
mov dx, offset OpenFile03
int 21h
jmp exitFromProgramm 
@2:
cmp ax, 04h
jne @3
mov ah, 09h
mov dx, offset OpenFile04
int 21h
jmp exitFromProgramm 
@3:
cmp ax, 05h
jne @4
mov ah, 09h
mov dx, offset OpenFile05
int 21h
jmp exitFromProgramm 
@4:
mov ah, 09h
mov dx, offset OpenFile0C
int 21h
jmp exitFromProgramm 
start:

    mov ax, @data         
	mov es, ax 		     
	           
	mov cl, ds:[80h] 
	mov si, 81h 
	lea di,file 
	rep movsb      
	
    mov ds,ax        
    lea si,file  
  
checkSpace1:    
    cmp byte ptr[si],0
    jne lets
    jmp errorCommandLine
lets:
    cmp byte ptr[si],' ' 
    jne readFile1
    inc si
    jmp checkSpace1
                     
readFile1:
         
    lea di,file1        
    
cycleReadNameFile1: 
         
    mov al,[si]               
    mov [di],al                   
    inc di
    inc si   
    
    cmp byte ptr[si],0
    jne lets1
    jmp errorCommandLine          
lets1:
    cmp byte ptr[si], '.'
    je readTxt
    cmp byte ptr[si], ' '
    jne cycleReadNameFile1	
	
setTXT: 
    cmp byte ptr[si], ' '
    je lets2
    jmp errorCommandLine
lets2:
    mov byte ptr[di],'.'
    inc di 
    mov byte ptr[di],'t'
    inc di   
    mov byte ptr[di],'x'
    inc di
    mov byte ptr[di],'t'
    inc di    
   jmp endReadNameFile1
  
readTXT:     

   cmp byte ptr[si],'.'
   je lets3
   jmp errorCommandLine 
lets3:
   mov byte ptr[di],'.'
   inc di
   inc si    
   cmp byte ptr[si],'t'
   je lets4
   jmp errorCommandLine 
lets4:      
   mov byte ptr[di],'t'
   inc di
   inc si  
   cmp byte ptr[si],'x'
   je lets5
   jmp errorCommandLine 
lets5:     
   mov byte ptr[di],'x'
   inc di
   inc si 
   cmp byte ptr[si],'t'
   je lets6
   jmp errorCommandLine 
lets6:   
   mov byte ptr[di],'t'
   inc di
   inc si   

endReadNameFile1: 

   mov  byte ptr [di],0
     
checkSpace2:        
	cmp byte ptr[si],0
	jne lets7
    jmp errorCommandLine
lets7:          
    cmp byte ptr[si],' ' 
    jne readNameFile2
    inc si
    jmp checkSpace2    
                                  
readNameFile2:   
	
    lea di,file2    
    
cycleReadNameFile2: 

    mov al,[si]   
    mov [di],al
       
    inc di
    inc si      
    cmp byte ptr[si],0
    jne lets9
    jmp errorCommandLine
lets9:
    cmp byte ptr[si], '.'
    je readTxt2
    cmp byte ptr[si], ' '
    jne cycleReadNameFile2	
                    	 
setTXT2:  
    
   cmp byte ptr[si], ' '
   je lets10
   jmp errorCommandLine
lets10:   
   mov byte ptr[di],'.'
   inc di 
   mov byte ptr[di],'t'
   inc di   
   mov byte ptr[di],'x'
   inc di
   mov byte ptr[di],'t'
   inc di    
   jmp endReadNameFile2
                   
readTXT2:

   cmp byte ptr[si],'.'
   jne errorCommandLine  
   
   mov byte ptr[di],'.'
   inc di
   inc si    
   dec size       
   
   cmp byte ptr[si],'t'
   jne errorCommandLine   
    
   mov byte ptr[di],'t'
   inc di
   inc si  
   dec size       
   
   cmp byte ptr[si],'x'
   jne errorCommandLine    
   
   mov byte ptr[di],'x'
   inc di
   inc si 
   dec size        
   
   cmp byte ptr[si],'t'
   jne errorCommandLine   
   
   mov byte ptr[di],'t'
   inc di
   inc si 
                            
endReadNameFile2:  

	mov  byte ptr [di],0 

checkSpace3:  
 
    cmp byte ptr[si],0
    je errorCommandLine   
    
    cmp byte ptr[si],' ' 
    jne readWord
    inc si
    jmp checkSpace3  
        
readWord:

    lea di,slovo
    add di,2
    mov al,[si]
    mov byte ptr[di],al  
    inc si
    inc di
    add slovo[1],1  
    
cycleReadWord:  

    mov al,[si]
    cmp byte ptr[si],' '
    je nextCheckCommandLine
    
    cmp byte ptr[si],0
    je nextCheckCommandLine 
    
    mov byte ptr[di],al  
    add slovo[1],1 
    
    inc si
    inc di
    jmp cycleReadWord 
    
    
nextCheckCommandLine:
    
    cmp byte ptr[si],' '
    je nextSymbolCheckCommandLine  
    
    cmp byte ptr[si],0
    je openFiles
    jmp errorCommandLine  
    
    nextSymbolCheckCommandLine:
    inc si   
    jmp nextCheckCommandLine
                     
errorCommandLine: 
  
  lea dx,errorMessage
  mov ah,9
  int 21h
  jmp exitFromProgramm  
 
openFiles:    

  	mov ah, 3Dh			      
	mov al, 00		
	mov cl,01h	        
	mov dx, offset file1        	  
	int 21h 
	 
	jc NoOpen     
	mov handler1,ax 
	
    mov ah, 3Dh			        
	mov al, 02h	
	mov cl,0h			       
	mov dx, offset file2         	      
	int 21h 
	 
	jc NoOpen
	mov handler2,ax
	jmp continue        
NoOpen:
    jmp ErrorOpen 
continue:
    xor di,di  
	lea dx,buf
	mov ah,3Fh  
    mov bx,handler1
    mov cx,1
    int 21h       
    
    mov al,buf[di]        
    cmp al,0Dh
    je setBeginFlag 

	mov ah,42h
    mov bx,handler1
    mov al,0  
    mov cx,0
    mov dx,0
    int 21h    
    jmp find    
    
setBeginFlag:  
    
    mov flagBeginFile,1
    jmp exitFromOutputInFile2     
                                      
find:      
   
    lea dx,buf
    lea si,slovo 
    add si,2  
    
    mov ah,3Fh  
    mov bx,handler1
    mov cx,1
    int 21h       
       
    cmp al,0
    jne cont1  
    jmp output 
cont1:
    cmp buf[di],0Ah
    jne cont2
    jmp find  
cont2:     
    cmp buf[di],0Dh
    jne cont3  
    jmp output 
cont3: 
    cmp buf[di],' '
    jne cont4
    jmp find   
cont4:     
    mov al,buf[di]  
    cmp al,[si] 
    jne  c1
    je c2  
c1:
jmp missWord
c2:
jmp findWord
    
    jmp find   

findWord:  

    inc si 
    mov cl,slovo[1]   
    dec cl    
    
cycleFindWord: 
    push cx
    lea dx,buf
    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h    
    pop cx     
    
    cmp cl,0  
    jg ifSizeNo0
    
    cmp al,0
    jne conti5
    jmp exit
conti5:
    cmp buf[di],' '
    jne conti6
    jmp moveNewLine
conti6:    
    cmp buf[di],'.'
    jne contin6
    jmp moveNewLine
contin6:    
    cmp buf[di],','
    jne contin
    jmp moveNewLine     
contin:    
    cmp buf[di],0Dh
    jne conti7
    jmp find
conti7:    
    jmp missWord
ifSizeNo0:      
     
    cmp al,0
    jne co1
    jmp output
co1:    
    mov al,buf[di]  
      
    cmp al,0Dh
    jne co2
    jmp output
co2:   
    cmp al,' '
    jne conti8
    jmp find
conti8:       
    cmp al,[si]
    jne missWord
          
    inc si

    loop cycleFindWord

    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h      
    
    cmp al,0
    jne conti9
    jmp exit     
conti9:    
    mov al,buf[di]
    
    cmp al,0Dh
    jne conti10
    jmp find
conti10:
    cmp al,'.'
    jne continue0
    je conti12    
continue0:
    cmp al,','
    jne continue10
    je conti12
continue10:
    cmp al,' '
    jne conti11
    je conti12 
conti11: 
    jmp find
conti12:
    jmp moveNewLine
missWord: 

    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h 

    cmp buf[di],' '
    jne conti13
    jmp find 
conti13:    
    cmp buf[di],0Dh
    jne conti14
    jmp output 
conti14:    
    cmp al,0
    je output
    
jmp missWord

moveNewLine: 
    
    mov ah,3Fh 
    mov bx,handler1
    mov cx,1
    int 21h   
    
    cmp al,0
    jne conti15
    jmp exit    
conti15:    
    cmp buf[di],0Dh
    jne moveNewLine 
           
    mov flagBeginFile,1
   jmp find 
    
output:
    cmp flagBeginFile,1
    je outputNoFirstStrings 
       
    mov ah,42h
    mov al,0
    mov bx,handler1    
    mov cx,0
    mov dx,0 
    int 21h     
    mov flagBeginFile,1
    jmp outInFile2 
outputNoFirstStrings:    
    
    xor di,di
    xor cx,cx
    mov ah,42h
    mov al,1
    mov bx,handler1    
    mov cx,-1
    mov dx,-2 
    int 21h   
        
    lea dx,buf   
    mov ah,3Fh 
    mov cx,1 
    mov bx,handler1
    int 21h       
    
    mov al,buf[di] 
       
    cmp buf[di],0Ah
    je outInFile2  
       
    jmp outputNoFirstStrings
    
outInFile2:          
     
    mov flagBeginFile,1
    mov ah,3Fh 
    mov cx,1 
    mov bx,handler1 
    lea dx,buf 
    int 21h   
    
    cmp al,0
    je exit
    
    cmp buf[di],0Dh
    je exitFromOutputInFile2  
    
    lea dx,buf
    xor al,al	  
    mov ah,40h
    mov cx,1
    mov bx,handler2
    int 21h      
         
 jmp outInFile2
 
exitFromOutputInFile2:
    lea dx,buf
    mov buf[di],0Dh
    mov ah,40h
    mov cx,1
    mov bx,handler2
    int 21h   
     
     lea dx,buf  
    mov buf[di],0Ah
    mov ah,40h
    mov cx,1
    mov bx,handler2
    int 21h   
    
   mov flagBeginFile,1 
   
   jmp find 
     
exit:     
    cmp handler1,0
    je closeFile2  
    
    mov ah,3Eh
    mov bx,handler1
    int 21h   
    
closeFile2:  
    cmp handler2,0
    je exitFromProgramm     
    
    mov ah,3Eh
    mov bx,handler2
    int 21h    
exitFromProgramm:   
 
    mov ax,4C00h
    int 21h   

end start