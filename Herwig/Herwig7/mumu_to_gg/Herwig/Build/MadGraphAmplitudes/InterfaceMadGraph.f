!This file gets filled from mg2Matchbox.py
!///////////////////////////////////////////////////////////////////////


       subroutine MGInitProc(file_card)
         IMPLICIT NONE
         character*(*) file_card
C         print*,"Reading inputs from: "
C         print*, TRIM(file_card)
         CALL setpara(file_card)
       END

!///////////////////////////////////////////////////////////////////////

       subroutine  MG_Calculate_wavefunctions_virt(proc, momenta,  virt)
     $   bind(c, name="MG_Calculate_wavefunctions_virt")
         IMPLICIT NONE
         REAL*8 momenta(0:40),virt(20)
         INTEGER proc



       END


!///////////////////////////////////////////////////////////////////////

       subroutine  MG_Calculate_wavefunctions_born(proc, momenta,  hel)
     $   bind(c, name="MG_Calculate_wavefunctions_born")
         IMPLICIT NONE
         REAL*8 momenta(0:40)
         INTEGER hel(0:10),proc

         IF (proc .EQ. 1) THEN
            CALL MG5_1_BORN(momenta,hel)
         ELSE
             WRITE(*,*) '##W02A WARNING No id found '
         ENDIF   


       END

!///////////////////////////////////////////////////////////////////////

       subroutine MG_Jamp(proc ,color,amp)
     $   bind(c, name="MG_Jamp")

         IMPLICIT NONE
         INTEGER    proc,color
         REAL*8 amp(0:1)
         COMPLEX*16 Jamp
         IF (proc .EQ. 1) THEN
            CALL MG5_1_GET_JAMP(color,Jamp)
         ELSE
             WRITE(*,*) '##W02A WARNING No id found '
         ENDIF   


         amp(0)=real(Jamp)
         amp(1)=aimag(Jamp)   
       END
       
!///////////////////////////////////////////////////////////////////////

       subroutine MG_LNJamp(proc ,color,amp)
     $   bind(c, name="MG_LNJamp")

         IMPLICIT NONE
         INTEGER    proc,color
         REAL*8 amp(0:1)
         COMPLEX*16 Jamp
         IF (proc .EQ. 1) THEN
            CALL MG5_1_GET_LNJAMP(color,Jamp)
         ELSE
             WRITE(*,*) '##W02A WARNING No id found '
         ENDIF   


         amp(0)=real(Jamp)
         amp(1)=aimag(Jamp)   
       END



!///////////////////////////////////////////////////////////////////////

       subroutine MG_NCol(proc ,color)
     $   bind(c, name="MG_NCol")
         IMPLICIT NONE
         INTEGER    proc,color
         IF (proc .EQ. 1) THEN
            CALL MG5_1_GET_NCOL(color)
         ELSE
             WRITE(*,*) '##W02A WARNING No id found '
         ENDIF   


       END

!///////////////////////////////////////////////////////////////////////

       subroutine MG_Colour(proc,i,j ,color)
     $   bind(c, name="MG_Colour")
         IMPLICIT NONE
         INTEGER    proc,color,i,j
         IF (proc .EQ. 1) THEN
            CALL MG5_1_GET_NCOLOR(i,j,color)
         ELSE
             WRITE(*,*) '##W02A WARNING No id found '
         ENDIF   


       END

!///////////////////////////////////////////////////////////////////////
       
       subroutine  MG_vxxxxx(p, n,inc,VC)
     $   bind(c, name='MG_vxxxxx')
         IMPLICIT NONE
         double precision p(0:3)
         double precision n(0:3)
         INTEGER inc
         double precision VC(0:7)
         double complex  VCtmp(0:4)
         double complex  Ninplus(6)
         double complex  Noutminus(6)
         double complex  Pinplus(6)
         double complex  Poutplus(6)
         double complex   denom
         double complex  IMAG1
         PARAMETER (IMAG1=(0D0,1D0))
         CALL IXXXXX(n, 0.0d0, +1, +1, Ninplus);  ! |n+>
         CALL OXXXXX(p, 0.0d0, +1, +1, Poutplus); ! <p+|
         CALL OXXXXX(n, 0.0d0, -1, +1, Noutminus);!  <n-|
         CALL IXXXXX(p, 0.0d0, +1, +1, Pinplus);  ! |p+>
         !<p+| gamma_mu |n+>
         VCtmp(0)=Ninplus(3)*Poutplus(5)+Ninplus(4)*Poutplus(6)+
     $             Ninplus(5)*Poutplus(3)+Ninplus(6)*Poutplus(4)
         VCtmp(1)=(Ninplus(5)*Poutplus(4)+Ninplus(6)*Poutplus(3)-
     $             Ninplus(3)*Poutplus(6)-Ninplus(4)*Poutplus(5))
         VCtmp(2)=(-IMAG1*(Ninplus(3)*Poutplus(6)+Ninplus(6) 
     $             * Poutplus(3))+IMAG1*(Ninplus(4)*Poutplus(5)
     $             + Ninplus(5)*Poutplus(4)));
         VCtmp(3)=(Ninplus(4)*Poutplus(6)+Ninplus(5)*Poutplus(3)-
     $              Ninplus(3)*Poutplus(5)-Ninplus(6)*Poutplus(4))
         denom= (Pinplus(3)*Noutminus(3)+Pinplus(4)
     $          *Noutminus(4)+Pinplus(5)*Noutminus(5)
     $          +Pinplus(6)*Noutminus(6))*sqrt(2.d0)
          if (inc.gt.1 )THEN
            denom=denom*-1.0d0
            if (abs(VCtmp(3)).ne.0.d0)THEN
             denom=denom* (VCtmp(3))/abs(VCtmp(3))
            endif
            if (abs(VCtmp(1)).ne.0.d0)THEN
              denom=denom* (VCtmp(1))/abs(VCtmp(1))
            endif
          endif
         VCtmp(0)=-1.0d0*VCtmp(0)/denom
         VCtmp(1)=-1.0d0*VCtmp(1)/denom
         VCtmp(2)=-1.0d0*VCtmp(2)/denom
         VCtmp(3)=-1.0d0*VCtmp(3)/denom
         VC(0)= real(VCtmp(0))
         VC(1)=aimag(VCtmp(0))  
         VC(2)= real(VCtmp(1))
         VC(3)=aimag(VCtmp(1))  
         VC(4)= real(VCtmp(2))
         VC(5)=aimag(VCtmp(2))  
         VC(6)= real(VCtmp(3))
         VC(7)=aimag(VCtmp(3))  
       END
