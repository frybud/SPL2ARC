;;;点坐标写出文件
(defun c:zhd ()
   ;(CMDLA0)
   (setq  ffn (getfiled "\n保存的坐标文件" "坐标" "txt" 1)
  ff   (open ffn "w")
  ss   (ssget '((0 . "POINT")))
  i     -1
   )
   (while (setq s1 (ssname ss (setq i (1+ i))))
       (setq pt (dxf 10 (entget s1))
			
     tx (strcat (rtos (car pt) 2 3)
             " "
             (rtos (cadr pt) 2 3)
            " "
             (rtos (caddr pt) 2 3)
           )
       )
       (write-line tx ff)
   )
   (close ff)
   (princ (strcat "\n 坐标写至=>" ffn))
   ;(CMDLA1)
   (princ)
)
(defun dxf (code elist) (cdr (assoc code elist)))