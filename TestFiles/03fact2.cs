/* Computes factorials:  tests recursive method calls, if, while, assignment */

public class fact2 {

   public static int factorial(int x) {
      if (x==0) return 1;
      else return x * factorial (x-1);
   }

   public static void main() {
     int i, gobble;
     i = 0;
     WriteLine ("TCCL recursive factorial test");
     while ( i < 15) {
        gobble =  factorial (i);
        WriteLine (gobble);
        i = i + 1;
     }   
   }
}
