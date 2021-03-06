(defun c:sr(/ ff finalscore numstr rsno score scorelst SplPtLst splptnum stnumlst stptnum tanscore)
	(setvar "cmdecho" 0 )
	(setvar "pdmode" 35)
	(print "start")
	(setq SplPtLst (sub_read_splpoint))
	(setq SplPtNum (length SplPtLst))
	
	(setq StNumLst  (sub_read_startpoint))
	(setq rsno (getint "\n输入读第几行结果:"))
	(setq StNumLst (nth rsno StNumLst))
	(setq tanscore (rtos (last StNumLst) 2))
	(setq StNumLst (reverse (cdr(reverse StNumLst))))
	(print StNumLst)
	(setq StPtNum (length StNumLst))
	(print StPtNum)
	;(setq StPtNum 10)  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;点数
	;(setq finalscore 10)
	;(setq scorelst nil)
	;(	while (> finalscore 0.15);;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;阈值1
	;	(setq StNumLst (sub_CreatStNumLst StPtNum SplPtNum))
	;	;(print StNumLst)
	;	(setq score (sub_judge SplPtLst SplPtNum StNumLst StPtNum))
	;	(setq  finalscore (sub_processscore score))
	;	(if (< finalscore 0.2) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;阈值2
	;		(progn
	;			;(print finalscore)
	;			(setq ff (open "E:/result.txt" "a"))
	;			(setq numstr "")
	;			(print StNumLst)
	;			(foreach numtp (reverse StNumLst)
	;				(setq numstr (strcat (itoa numtp) " " numstr))
	;			)
	;			;(print numstr)
	;			(write-line (strcat numstr " ") ff)
	;			(close ff)
	;			;(setq scorelst (append scorelst (list StNumLst)))
	;			;(if (/= nil scorelst)
	;			;	(setq ff (open "E:/result.txt" "w"))
	;			;	(foreach tx scorelst
	;			;		(write-line tx ff)
	;			;	)
	;			;	(close ff)
	;			;)
	;		)
	;	)
	;)
	;(print finalscore)
	;(print scorelst)
	;(sub_draw SplPtLst SplPtNum StNumLst StPtNum)
	;(foreach point SplPtLst
	;	(entmake (list '(0 . "point")  (cons 10 point) ))
	;)
	(sub_judge SplPtLst SplPtNum StNumLst StPtNum)
	(sub_show_drawround SplPtLst SplPtNum)
	(entmake (list '(0 . "TEXT") (cons 1 tanscore) (cons 10 '(0 0)) (cons 40 10000)))
	(print "succeed")
	(princ)
)

(defun sub_processscore(score / maxscore)
	(setq maxscore 0)
	(foreach mintp  score
		(if (< maxscore mintp)
			(setq maxscore mintp)
		)
	)
	maxscore
)

(defun sub_CreatStNumLst(StPtNum SplPtNum / i mintab ranlst ranlstlt rannum tab)
	(setq ranlst nil)
	(repeat StPtNum
		(setq rannum  (fix (rem (getvar "CPUTICKS") SplPtNum)))
		
		(setq ranlst (append ranlst (list rannum)))
	)
	(setq ranlst
		(vl-sort ranlst
			(function (lambda (e1 e2)		(< e1 e2)		)	) )	)
	(setq ranlstlt (sub_listmallt ranlst))
	(setq i 0)
	(setq mintab SplPtNum)
	(repeat (length ranlst)
		(setq tab (- (if (= i 0) (+ SplPtNum (nth i ranlst)) (nth i ranlst)) (nth i ranlstlt)))
		;(print tab)
		(setq mintab (min mintab tab))
		(setq i (1+ i))
	)
	;(print mintab)
	(if (or (< mintab 6) (/= StPtNum (length ranlst)))
		(setq ranlst (sub_CreatStNumLst StPtNum SplPtNum))
	)
	ranlst
)



(defun sub_judge(SplPtLst SplPtNum StNumLst StPtNum / i ipt pt ptlt ptltm ptolt ptort ptrt ptrtm rptlt rptrt stnumlstlt stnumlstltmid stnumlstrt stnumlstrtmid tanscore tanscorelst)
	;(print "judge")
	(setq StNumLstRt (sub_listmalrt StNumLst))
	(setq StNumLstLt (sub_listmallt StNumLst))
	(setq i 0)
	(setq StNumLstLtMid nil)
	(setq StNumLstRtMid nil)
	(repeat  StPtNum
		(setq StNumLstLtMid (append StNumLstLtMid(list (sub_imid (nth i StNumLstLt) (nth i StNumLst) SplPtNum))))
		(setq StNumLstRtMid (append StNumLstRtMid(list (sub_imid (nth i StNumLst) (nth i StNumLstRt) SplPtNum))))
		(setq i (1+ i))
	)
	(setq ipt 0)
	(setq tanscorelst nil)
	(repeat StPtNum
		(setq ptlt (nth (nth ipt StNumLstLt) SplPtLst))
		(setq ptltm (nth (nth ipt StNumLstLtMid) SplPtLst))
		(setq pt (nth (nth ipt StNumLst) SplPtLst))
		(setq ptrtm (nth (nth ipt StNumLstRtMid) SplPtLst))
		(setq ptrt (nth (nth ipt StNumLstRt) SplPtLst))
		(setq ptolt  (sub_findcenter ptlt ptltm pt))
		(setq ptort  (sub_findcenter pt ptrtm ptrt))
		(setq rptlt (distance pt ptolt))
		(setq rptrt (distance pt ptort))
		;(entmake (list '(0 . "LINE") (cons 10 pt) (cons 11 ptlt)))
		(entmake (list '(0 . "ARC") (cons 10 ptolt) (cons 40 rptlt) (cons 51 (angle ptolt ptlt)) (cons 50 (angle ptolt pt ) )(cons 62 1)))
		(setq  tanscore (abs (sub_judgetan pt ptolt ptort)))
		(setq tanscorelst (append tanscorelst (list tanscore)))
		;(entmake (list '(0 . "TEXT") (cons 1 (rtos tanscore 2 8)) (cons 10 pt) (cons 40 2000)))
		
		(setq ipt (1+ ipt))
	)
	;(print StNumLstLt)
	;(print StNumLstLtMid)
	;(print StNumLst)
	;(print StNumLstRtMid)
	;(print StNumLstRt)
	tanscorelst
)
(defun sub_judgetan(pt ptolt ptort / tanpt)
	(setq tanpt (- (angle pt ptolt) (angle pt ptort)))
	tanpt
)
(defun sub_findcenter(pt1 pt2 pt3 / a ans b c d e f r x x1 x2 x3 y y1 y2 y3)
	(setq x1 (car pt1))	(setq x2 (car pt2))	(setq x3 (car pt3))
	(setq y1 (cadr pt1))	(setq y2 (cadr pt2))	(setq y3 (cadr pt3))
	(setq a (* 2 (- x2 x1)))
	(setq b (* 2 (- y2 y1)))
	(setq c (- (+ (* x2 x2) (* y2 y2)) (+ (* x1 x1) (* y1 y1))))
	(setq d (* 2 (- x3 x2)))
	(setq e (* 2 (- y3 y2)))
	(setq f (- (+ (* x3 x3) (* y3 y3)) (+ (* x2 x2) (* y2 y2))))
	(setq x (/ (- (* b f) (* e c)) (- (* b d) (* e a)) ) )
	(setq y (/ (- (* d c) (* a f)) (- (* b d) (* e a)) ) )
	(setq r (sqrt (+ (* (- x x1) (- x x1)) (* (- y y1) (- y y1)))))
	(setq ans (list x y))
	ans
)
(defun sub_imid(i1 i2 totalnum / ans d-value)
	(setq D-value (- i2 i1))
	(if (< D-value 0)
		(setq D-value (+  D-value totalnum))
	)
	(setq D-value (fix (* D-value 0.5)))
	(setq ans (+ i1 D-value))
	(if (>= ans totalnum)
		(setq ans (- ans totalnum))
	)
	ans
)
(defun sub_read_splpoint(/ data ff fhb1)
	(setq ff (open "E:/point.txt" "r"))
	(while (setq data (read-line ff))
		(setq data (read (strcat "(" data ")")))
		(setq fhb1 (append fhb1 (list data)))	)
	(close ff)
	fhb1)
(defun sub_read_startpoint(/ data ff fhb1)
	;(setq file (getfiled "opendata" "" "txt" 4))
	;(setq ff (open file "r"))
	(setq ff (open "E:/result10arc.txt" "r"))
	(while (setq data (read-line ff))
		(setq data (read (strcat "(" data ")")))
		(setq fhb1 (append fhb1 (list data))))
	(close ff)
	fhb1 )

(defun sub_show_drawround(fhb1 num / i1)
	(entmake (list '(0 . "LAYER")'(100 . "AcDbSymbolTableRecord")
	'(100 . "AcDbLayerTableRecord")'(70 . 0)'(6 . "Continuous")	
	(cons 2 "S-PATT")		(cons 62 153)	(cons 290 1)	) )
	(setq i1 0)
	(repeat num   ;;一共点数!!!
		;(print (nth i1 fhb1) )
		;(entmake (list '(0 . "point")  (cons 10 (nth i1 fhb1)) ))
		(entmake (list '(0 . "LINE") (cons 10 (nth i1 fhb1)) (cons 11 (nth i1 (sub_listmalrt fhb1))) (cons 8 "S-PATT")))
		(setq i1 (1+ i1))))
(defun sub_listmalrt(lst1 / lst2)
	(setq lst2 (cdr lst1))
	(setq lst2 (reverse (cons (car lst1) (reverse lst2)))))
(defun sub_listmallt(lst1 / lst2)
	(setq lst2 (cons (last lst1) (reverse (cdr (reverse lst1))))))



(defun sub_draw (SplPtLst SplPtNum StNumLst StPtNum / i ipt pt ptlt ptltm ptolt ptort ptrt ptrtm rptlt rptrt stnumlstlt stnumlstltmid stnumlstrt stnumlstrtmid tanscore tanscorelst)
	;(print "judge")
	(setq StNumLstRt (sub_listmalrt StNumLst))
	(setq StNumLstLt (sub_listmallt StNumLst))
	(setq i 0)
	(setq StNumLstLtMid nil)
	(setq StNumLstRtMid nil)
	(repeat  StPtNum
		(setq StNumLstLtMid (append StNumLstLtMid(list (sub_imid (nth i StNumLstLt) (nth i StNumLst) SplPtNum))))
		(setq StNumLstRtMid (append StNumLstRtMid(list (sub_imid (nth i StNumLst) (nth i StNumLstRt) SplPtNum))))
		(setq i (1+ i))
	)
	(setq ipt 0)
	(setq tanscorelst nil)
	(repeat StPtNum
		(setq ptlt (nth (nth ipt StNumLstLt) SplPtLst))
		(setq ptltm (nth (nth ipt StNumLstLtMid) SplPtLst))
		(setq pt (nth (nth ipt StNumLst) SplPtLst))
		(setq ptrtm (nth (nth ipt StNumLstRtMid) SplPtLst))
		(setq ptrt (nth (nth ipt StNumLstRt) SplPtLst))
		(setq ptolt  (sub_findcenter ptlt ptltm pt))
		(setq ptort  (sub_findcenter pt ptrtm ptrt))
		(setq rptlt (distance pt ptolt))
		(setq rptrt (distance pt ptort))
		;(entmake (list '(0 . "LINE") (cons 10 pt) (cons 11 ptlt)))
		(entmake (list '(0 . "ARC") (cons 10 ptolt) (cons 40 rptlt) (cons 51 (angle ptolt ptlt)) (cons 50 (angle ptolt pt ))))
		(setq  tanscore (abs (sub_judgetan pt ptolt ptort)))
		(setq tanscorelst (append tanscorelst (list tanscore)))
		;(entmake (list '(0 . "TEXT") (cons 1 (rtos tanscore 2 8)) (cons 10 pt) (cons 40 2000)))
		
		(setq ipt (1+ ipt))
	)
	;(print StNumLstLt)
	;(print StNumLstLtMid)
	;(print StNumLst)
	;(print StNumLstRtMid)
	;(print StNumLstRt)
	tanscorelst
)

