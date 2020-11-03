
import com.utils.validator.TransactionValidator;
import junit.framework.TestCase;

public class TransactionValidatorTest extends TestCase {

  private String transNo;
  private String paymentNo;
  private String hexValue;
  private TransactionValidator tv;
 
  /**
   * Sets up the test fixture.
   *
   * Called before every test case method.
   */
  protected void setUp() {
    transNo      = "IP0101015326";
    paymentNo    = "4050";
    hexValue     = "E";
    tv           = new TransactionValidator();
  }

  /**
   * Tears down the test fixture.
   *
   * Called after every test case method.
   */
  protected void tearDown() {
      // release objects under test here, if necessary
  }

  /**
   * Tests that the string is converted to
   * an integer array correctly
   */
  public void testSetTransNumbers(){
    int[] tempNumbers = tv.setTransNumbers( transNo );
    int[] transNumbers = {6,2,3,5,1,0};
    for(int i=0; i<6; i++){
      assertEquals( tempNumbers[i], transNumbers[i] );
    }
  }

  /**
   * Tests the payment string is converted to
   * an integer array correctly
   */
  public void testSetPaymentNumbers(){
    int[] tempNumbers = tv.setPaymentNumbers( "8580" );
    int[] paymentNumbers = {0,8,5,8,0,8};
    for(int i=0; i<6; i++){
      assertEquals( tempNumbers[i], paymentNumbers[i] );
    }
  }

  /**
   * Tests that the weights are calculated correctly
   */
  public void testSetWeights(){
    int[] transNos   = tv.setTransNumbers( transNo );
    int[] paymentNos = tv.setPaymentNumbers( paymentNo );
    int[] weights = tv.setWeights( transNos, paymentNos );
    int[] actualWeights = {0, 10, 0, 20, 0, 0};
    for(int i=0;i<6;i++){
      assertEquals( weights[i], actualWeights[i] );
    }
  }

  /**
   * Check that the total calculated is correct
   */
  public void testGetWeightsTotal(){
    int[] weights = {0, 10, 0, 20, 0, 0};
    int total = tv.getWeightsTotal( weights );
    assertEquals( 30, total );
  }

  /**
   * Check that the correct hexadecimal value is returned
   */
  public void testGetHexValue(){
    String actualHexValue = "E";
    String hexValue = tv.getHexValue( 14 );
    assertEquals( actualHexValue, hexValue );
  }

  /**
   * Check that given a transaction number, payment number
   * and hex value, the correct validation boolean is returned
   */
  public void testValidate(){
    boolean expected = true;
    boolean actual = tv.validate( hexValue, transNo, paymentNo );
    assertEquals( expected, actual );
  }
}
