' additional init
' 20200826
'
Waitms 100
K_mode = K_mode_eeram
'
Mat(1) = Mat_eeram(1)
Mat(2) = Mat_eeram(2)
Mat(3) = Mat_eeram(3)
Mat(4) = Mat_eeram(4)
Mat(5) = Mat_eeram(5)
Mat(6) = Mat_eeram(6)
Mat(7) = Mat_eeram(7)
Mat(8) = Mat_eeram(8)
Gosub Copy_mat
' Turn on:
M(1) = &B00001001
M(2) = &B00001001
M(3) = &B00001001
M(4) = &B00001001
M(5) = &B00001001
M(6) = &B00001001
M(7) = &B00001001
M(8) = &B00001001
Gosub Send_data