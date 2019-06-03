import 'package:openfoodfacts/openfoodfacts.dart';

class OpenFoodLogic {
  OpenFoodLogic._();
  static final OpenFoodLogic ofl = OpenFoodLogic._();
  
  Future<Product> getProduct(String barcode) async {
    ProductResult result = await OpenFoodAPIClient.getProductRaw(barcode);

    if (result.status == 1) {
      return result.product;
    }

    return null;
  }
}
