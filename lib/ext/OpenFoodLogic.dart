import 'package:openfoodfacts/openfoodfacts.dart';

class OpenFoodLogic {
  OpenFoodLogic._();
  static final OpenFoodLogic ofl = OpenFoodLogic._();


  void getImages(String barcode) async {
    Product p = await getProduct(barcode);
    print("Brands : ${p.brands}");
    ImageList imgList = p.selectedImages;
    List<ProductImage> pImgList = imgList.list;
    pImgList.forEach((f) => print(f.field));
  }

  Future<Product> getProduct(String barcode) async {
    ProductResult result = await OpenFoodAPIClient.getProductRaw(barcode);

    if (result.status == 1) {
      return result.product;
    }
  }
}