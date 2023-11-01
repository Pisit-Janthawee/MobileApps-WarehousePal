import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryCompany.dart';
import 'package:warehouse_mnmt/Page/Model/DeliveryRate.dart';
import 'package:warehouse_mnmt/Page/Model/Product.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel_ndProperty.dart';
import 'package:warehouse_mnmt/Page/Model/ProductModel_stProperty.dart';
import 'package:warehouse_mnmt/Page/Model/Purchasing_item.dart';
import 'package:warehouse_mnmt/Page/Model/Selling.dart';
import 'package:warehouse_mnmt/Page/Model/Shop.dart';
import '../Page/Model/Customer.dart';
import '../Page/Model/CustomerAdress.dart';
import '../Page/Model/Dealer.dart';
import '../Page/Model/ProductCategory.dart';
import '../Page/Model/ProductLot.dart';

import '../Page/Model/Profile.dart';
import '../Page/Model/Purchasing.dart';
import '../Page/Model/Selling_item.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._init();
  static Database? _database;

  DatabaseManager._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('main85.db');
    return _database!;
  }

  // Initial DB
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(createTableProfile);
      await db.execute(createTableShop);
      await db.execute(createTableProduct);
      await db.execute(createTableProductCategory);
      await db.execute(createTableProductModel);
      await db.execute(createTableProductModel_stProperty);
      await db.execute(createTableProductModel_ndProperty);
      await db.execute(createTableProductLot);
      await db.execute(createTablePurchasing);
      await db.execute(createTablePurchasingItems);
      await db.execute(createTableDealer);
      await db.execute(createTableSelling);
      await db.execute(createTableSellingItem);
      await db.execute(createTableCustomer);
      await db.execute(createTableCustomerAddress);
      await db.execute(createTableDeliveryCompany);
      await db.execute(createTableDeliveryRate);
    });
  }

  static const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL';
  static const boolType = 'BOOLEAN NOT NULL';
  static const integerType = 'INTEGER';
  static const textType = 'TEXT';
  static const doubleType = 'REAL';

  static final createTableProfile = """
  CREATE TABLE IF NOT EXISTS $tableProfile (
        ${ProfileFields.id} $idType,
  ${ProfileFields.name} $textType,
  ${ProfileFields.phone} $textType,
  ${ProfileFields.image} $textType,
  ${ProfileFields.loginDateTime} $textType,
  ${ProfileFields.isDisable} $boolType,
  ${ProfileFields.isDarkTheme} $boolType,
  ${ProfileFields.pin} $textType
      );""";

  static final createTableShop = """
  CREATE TABLE IF NOT EXISTS $tableShop (
       ${ShopFields.shopid} $idType,
  ${ShopFields.name} $textType,
  ${ShopFields.phone} $textType,
  ${ShopFields.image} $textType,
  ${ShopFields.dcId} $integerType,
  ${ShopFields.profileId} $integerType

      );""";
  // Product (6 Tables)
  static final createTableProduct = """
  CREATE TABLE IF NOT EXISTS $tableProduct (
       ${ProductFields.prodId} $idType,
  ${ProductFields.prodName} $textType,
  ${ProductFields.prodDescription} $textType,
  ${ProductFields.prodImage} $textType,
  ${ProductFields.prodCategId} $integerType,
  ${ProductFields.shopId} $integerType
      );""";

  static final createTableProductCategory = """
  CREATE TABLE IF NOT EXISTS $tableProductCategory (
  ${ProductCategoryFields.prodCategId} $idType,
  ${ProductCategoryFields.prodCategName} $textType,
  ${ProductCategoryFields.shopId} $integerType
      );""";

  static final createTableProductModel = """
  CREATE TABLE IF NOT EXISTS $tableProductModel (
  ${ProductModelFields.prodModelId} $idType,
  ${ProductModelFields.prodModelname} $textType,
  ${ProductModelFields.stProperty} $textType,
  ${ProductModelFields.ndProperty} $textType,
  ${ProductModelFields.cost} $integerType,
  ${ProductModelFields.price} $integerType,
  ${ProductModelFields.weight} $doubleType,
  ${ProductModelFields.prodId} $integerType
      );""";
  static final createTableProductModel_stProperty = """
  CREATE TABLE IF NOT EXISTS $tableProductModel_stProperty (
  ${ProductModel_stPropertyFields.pmstPropId} $idType,
  ${ProductModel_stPropertyFields.pmstPropName} $textType,
  ${ProductModel_stPropertyFields.prodModelId} $integerType
      );""";
  static final createTableProductModel_ndProperty = """
  CREATE TABLE IF NOT EXISTS $tableProductModel_ndProperty (
  ${ProductModel_ndPropertyFields.pmndPropId} $idType,
  ${ProductModel_ndPropertyFields.pmndPropName} $textType,
  ${ProductModel_ndPropertyFields.prodModelId} $integerType
      );""";
  static final createTableProductLot = """
  CREATE TABLE IF NOT EXISTS $tableProductLot (
  ${ProductLotFields.prodLotId} $idType,
  ${ProductLotFields.orderedTime} $textType,
  ${ProductLotFields.amount} $textType,
  ${ProductLotFields.remainAmount} $integerType,
  ${ProductLotFields.purId} $integerType,
  ${ProductLotFields.isReceived} $boolType, 
  ${ProductLotFields.prodModelId} $integerType
      );""";
  // Product
  // Purchasing
  static final createTablePurchasing = """
  CREATE TABLE IF NOT EXISTS $tablePurchasing (
  ${PurchasingFields.purId} $idType,
  ${PurchasingFields.orderedDate} $textType,
  ${PurchasingFields.dealerId} $integerType,

  ${PurchasingFields.shippingCost} $integerType,
  ${PurchasingFields.amount} $integerType,
  ${PurchasingFields.total} $integerType,
  ${PurchasingFields.isReceive} $boolType,
  ${PurchasingFields.shopId} $integerType
      );""";
  static final createTablePurchasingItems = """
  CREATE TABLE IF NOT EXISTS $tablePurchasingItems (
  ${PurchasingItemsFields.purItemsId} $idType,
  ${PurchasingItemsFields.prodId} $integerType,
  ${PurchasingItemsFields.prodModelId} $integerType,
  ${PurchasingItemsFields.amount} $integerType,
  ${PurchasingItemsFields.total} $integerType,
  ${PurchasingItemsFields.purId} $integerType
      );""";
  static final createTableDealer = """
  CREATE TABLE IF NOT EXISTS $tableDealer (
  ${DealerFields.dealerId} $idType,
  ${DealerFields.dName} $textType,
  ${DealerFields.dAddress} $textType,
  ${DealerFields.dPhone} $textType,
${DealerFields.shopId} $integerType
      );""";
  // New Creation
  static final createTableSelling = """
  CREATE TABLE IF NOT EXISTS $tableSelling (
  ${SellingFields.selId} $idType,
  ${SellingFields.orderedDate} $textType,
  ${SellingFields.customerId} $integerType,
  ${SellingFields.cAddreId} $integerType,
  ${SellingFields.deliveryCompanyId} $integerType,
  ${SellingFields.shippingCost} $integerType,
  ${SellingFields.amount} $integerType,
  ${SellingFields.discountPercent} $integerType,
  ${SellingFields.total} $integerType,
  ${SellingFields.profit} $integerType,
  ${SellingFields.speacialReq} $textType,
  ${SellingFields.isDelivered} $boolType,
  ${SellingFields.shopId} $integerType
      );""";
  static final createTableSellingItem = """
  CREATE TABLE IF NOT EXISTS $tableSellingItem (
  ${SellingItemFields.selItemId} $idType,
  ${SellingItemFields.prodId} $integerType,
  ${SellingItemFields.prodModelId} $integerType,
  ${SellingItemFields.prodLotId} $integerType,
  ${SellingItemFields.amount} $integerType,
  ${SellingItemFields.total} $integerType,
  ${SellingItemFields.selId} $integerType
      );""";
  static final createTableCustomer = """
  CREATE TABLE IF NOT EXISTS $tableCustomer (
  ${CustomerFields.cusId} $idType,
  ${CustomerFields.cName} $textType,
  ${CustomerFields.shopId} $integerType
      );""";
  static final createTableCustomerAddress = """
  CREATE TABLE IF NOT EXISTS $tableCustomerAddress (
  ${CustomerAddressFields.cAddreId} $idType,
  ${CustomerAddressFields.cAddress} $textType,
  ${CustomerAddressFields.cPhone} $textType,
  ${CustomerAddressFields.cusId} $integerType
      );""";
  // New

  static final createTableDeliveryCompany = """
  CREATE TABLE IF NOT EXISTS $tableDeliveryCompany (  
  ${DeliveryCompanyFields.dcId} $idType,
  ${DeliveryCompanyFields.dcName} $textType,
  ${DeliveryCompanyFields.dcisRange} $boolType,
  ${DeliveryCompanyFields.fixedDeliveryCost} $integerType,
  ${DeliveryCompanyFields.shopId} $integerType
      );""";
  static final createTableDeliveryRate = """
  CREATE TABLE IF NOT EXISTS $tableDeliveryRate (
  ${DeliveryRateFields.rId} $idType,
  ${DeliveryRateFields.weightRange} $textType,
  ${DeliveryRateFields.cost} $integerType,
  ${DeliveryRateFields.dcId} $integerType
      );""";

  // Profile
  Future<Profile> createProfile(Profile profile) async {
    final db = await instance.database;

    final id = await db.insert(tableProfile, profile.toJson());
    return profile.copy(id: id);
  }

  Future<List<Profile>> readAllProfiles() async {
    final db = await instance.database;
    final orderBy = '${ProfileFields.id} ASC';

    final result = await db.query(tableProfile, orderBy: orderBy);
    return result.map((json) => Profile.fromJson(json)).toList();
  }

  Future<Profile?> readProfile(int id) async {
    final db = await instance.database;
    final maps = await db.query(tableProfile,
        columns: ProfileFields.values,
        where: '${ProfileFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Profile.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await instance.database;
    return db.update(tableProfile, profile.toJson(),
        where: '${ProfileFields.id} = ?', whereArgs: [profile.id]);
  }

  Future<int> deleteProfile(int id) async {
    final db = await instance.database;
    return db.delete(tableProfile,
        where: '${ProfileFields.id} = ?', whereArgs: [id]);
  }

  // Profile

  // Shop
  Future<Shop> createShop(Shop shop) async {
    final db = await instance.database;

    final id = await db.insert(tableShop, shop.toJson());
    return shop.copy(shopid: id);
  }

  Future<List<Shop>> readAllShops() async {
    final db = await instance.database;
    final orderBy = '${ShopFields.shopid} ASC';
    final result = await db.query(tableShop, orderBy: orderBy);
    return result.map((json) => Shop.fromJson(json)).toList();
  }

  Future<Shop> readShop(int id) async {
    final db = await instance.database;
    final maps = await db.query(tableShop,
        columns: ShopFields.values,
        where: '${ShopFields.shopid} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Shop.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<int> updateShop(Shop shop) async {
    final db = await instance.database;
    return db.update(tableShop, shop.toJson(),
        where: '${ShopFields.shopid} = ?', whereArgs: [shop.shopid]);
  }

  Future<int> deleteShop(int id) async {
    final db = await instance.database;
    return db
        .delete(tableShop, where: '${ShopFields.shopid} = ?', whereArgs: [id]);
  }

// Shop

// Product
  Future<List<Product>> readAllProducts(int shopId) async {
    final db = await instance.database;
    final orderBy = '${ProductFields.prodId} DESC';
    final result = await db.query(tableProduct,
        columns: ProductFields.values,
        where: '${ProductFields.shopId} = ?',
        whereArgs: [shopId],
        orderBy: orderBy);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> readAllProductsByName(int shopId, name) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM $tableProduct WHERE ${ProductFields.prodName} LIKE '${name}%'");
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Product>> readAllProductsByCategory(
      int shopId, int categoryId) async {
    final db = await instance.database;
    final orderBy = '${ProductFields.prodId} DESC';
    final result = await db.rawQuery(
        "SELECT * FROM $tableProduct WHERE ${ProductFields.prodCategId} = ${categoryId} ORDER BY ${orderBy}");
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> createProduct(Product product) async {
    final db = await instance.database;
    final id = await db.insert(tableProduct, product.toJson());
    return product.copy(prodId: id);
  }

  Future<int> updateProduct(Product product) async {
    final db = await instance.database;
    return db.update(tableProduct, product.toJson(),
        where: '${ProductFields.prodId} = ?', whereArgs: [product.prodId]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await instance.database;
    return db.delete(tableProduct,
        where: '${ProductFields.prodId} = ?', whereArgs: [id]);
  }

// Product

// ProductCategory
  Future<ProductCategory> createProductCategory(
      ProductCategory prodCateg) async {
    final db = await instance.database;
    final id = await db.insert(tableProductCategory, prodCateg.toJson());
    return prodCateg.copy(prodCategId: id);
  }

  Future<List<ProductCategory>> readProductCategoryReturnName(
      int prodId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT ${ProductCategoryFields.prodCategName} FROM $tableProductCategory WHERE ${ProductCategoryFields.prodCategId} = ${prodId}");
    return result.map((json) => ProductCategory.fromJson(json)).toList();
  }

  Future<List<ProductCategory>> readAllProductCategorys(int shopId) async {
    final db = await instance.database;
    final orderBy = '${ProductCategoryFields.prodCategId} DESC';
    final result = await db.query(tableProductCategory,
        columns: ProductCategoryFields.values,
        where: '${ProductCategoryFields.shopId} = ?',
        orderBy: orderBy,
        whereArgs: [shopId]);
    return result.map((json) => ProductCategory.fromJson(json)).toList();
  }

  Future<int> updateProductCategory(ProductCategory productLot) async {
    final db = await instance.database;
    return db.update(tableProductCategory, productLot.toJson(),
        where: '${ProductCategoryFields.prodCategId} = ?',
        whereArgs: [productLot.prodCategId]);
  }

  Future<int> deleteProductCategory(int id) async {
    final db = await instance.database;
    return db.delete(tableProductCategory,
        where: '${ProductCategoryFields.prodCategId} = ?', whereArgs: [id]);
  }

// ProductCategory
// ProductModel
  Future<ProductModel> createProductModel(ProductModel prodModel) async {
    final db = await instance.database;
    final id = await db.insert(tableProductModel, prodModel.toJson());
    return prodModel.copy(prodModelId: id);
  }

  Future<int> updateProductModel(ProductModel model) async {
    final db = await instance.database;
    return db.update(tableProductModel, model.toJson(),
        where: '${ProductModelFields.prodModelId} = ?',
        whereArgs: [model.prodModelId]);
  }

  Future<List<ProductModel>> readAllProductModels() async {
    final db = await instance.database;
    final orderBy = '${ProductModelFields.prodModelId} ASC';
    final result = await db.query(tableProductModel, orderBy: orderBy);
    return result.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> readAllProductModelsInProduct(int prodId) async {
    final db = await instance.database;
    final orderBy = '${ProductModelFields.prodModelId} DESC';
    final result = await db.query(tableProductModel,
        columns: ProductModelFields.values,
        where: '${ProductModelFields.prodId} = ?',
        orderBy: orderBy,
        whereArgs: [prodId]);
    return result.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<int> deleteProductModel(int id) async {
    final db = await instance.database;
    return db.delete(tableProductModel,
        where: '${ProductModelFields.prodModelId} = ?', whereArgs: [id]);
  }
  // 1st Property

  Future<ProductModel_stProperty> create1stProperty(
      ProductModel_stProperty property) async {
    final db = await instance.database;
    final id = await db.insert(tableProductModel_stProperty, property.toJson());
    return property.copy(pmstPropId: id);
  }

  Future<List<ProductModel_stProperty>> readAll1stProperty(
      int prodModelID) async {
    final db = await instance.database;
    final orderBy = '${ProductModel_stPropertyFields.pmstPropId} ASC';
    final result = await db.query(tableProductModel_stProperty,
        columns: ProductModel_stPropertyFields.values,
        where: '${ProductModel_stPropertyFields.prodModelId} = ?',
        whereArgs: [prodModelID],
        orderBy: orderBy);
    return result
        .map((json) => ProductModel_stProperty.fromJson(json))
        .toList();
  }

  Future<int> update1stProperty(ProductModel_stProperty property) async {
    final db = await instance.database;
    return db.update(tableProductModel_stProperty, property.toJson(),
        where: '${ProductModel_stPropertyFields.pmstPropId} = ?',
        whereArgs: [property.pmstPropId]);
  }

  Future<int> delete1stProperty(int id) async {
    final db = await instance.database;
    return db.delete(tableProduct,
        where: '${ProductFields.prodId} = ?', whereArgs: [id]);
  }

  // 1st Property

  // 2nd Property
  Future<ProductModel_ndProperty> create2ndProperty(
      ProductModel_ndProperty property) async {
    final db = await instance.database;
    final id = await db.insert(tableProductModel_ndProperty, property.toJson());
    return property.copy(pmndPropId: id);
  }

  Future<List<ProductModel_ndProperty>> readAll2ndProperty(
      int prodModelID) async {
    final db = await instance.database;
    final orderBy = '${ProductModel_ndPropertyFields.pmndPropId} ASC';
    final result = await db.query(tableProductModel_ndProperty,
        columns: ProductModel_ndPropertyFields.values,
        where: '${ProductModel_ndPropertyFields.prodModelId} = ?',
        whereArgs: [prodModelID],
        orderBy: orderBy);
    return result
        .map((json) => ProductModel_ndProperty.fromJson(json))
        .toList();
  }

  Future<int> update2ndProperty(ProductModel_ndProperty property) async {
    final db = await instance.database;
    return db.update(tableProductModel_ndProperty, property.toJson(),
        where: '${ProductModel_ndPropertyFields.pmndPropId} = ?',
        whereArgs: [property.pmndPropId]);
  }

  Future<int> delete2ndProperty(int id) async {
    final db = await instance.database;
    return db.delete(tableProductModel_ndProperty,
        where: '${ProductModel_ndPropertyFields.pmndPropId} = ?',
        whereArgs: [id]);
  }
  // 2nd Property

  // Product lot
  Future<List<ProductLot>> readAllProductLots() async {
    final db = await instance.database;
    final orderBy = '${ProductLotFields.prodModelId} ASC';
    final result = await db.query(tableProductLot, orderBy: orderBy);
    return result.map((json) => ProductLot.fromJson(json)).toList();
  }

  Future<List<ProductLot>> readAllProductLotsByModelID(int prodModelID) async {
    final db = await instance.database;
    final orderBy = '${ProductLotFields.prodLotId} DESC';
    final result = await db.query(tableProductLot,
        columns: ProductLotFields.values,
        where: '${ProductLotFields.prodModelId} = ?',
        whereArgs: [prodModelID],
        orderBy: orderBy);
    return result.map((json) => ProductLot.fromJson(json)).toList();
  }

  Future<List<ProductLot>> readAllProductLotsBypurID(int purID) async {
    final db = await instance.database;
    final orderBy = '${ProductLotFields.prodLotId} DESC';
    final result = await db.query(tableProductLot,
        columns: ProductLotFields.values,
        where: '${ProductLotFields.purId} = ?',
        whereArgs: [purID],
        orderBy: orderBy);
    return result.map((json) => ProductLot.fromJson(json)).toList();
  }

  Future<ProductLot> createProductLot(ProductLot productLot) async {
    final db = await instance.database;
    final id = await db.insert(tableProductLot, productLot.toJson());
    return productLot.copy(prodLotId: id);
  }

  Future<int> updateProductLot(ProductLot productLot) async {
    final db = await instance.database;
    return db.update(tableProductLot, productLot.toJson(),
        where: '${ProductLotFields.prodLotId} = ?',
        whereArgs: [productLot.prodLotId]);
  }

  Future<int> deleteProductLot(int prodLotId) async {
    final db = await instance.database;
    return db.delete(tableProductLot,
        where: '${ProductLotFields.prodLotId} = ?', whereArgs: [prodLotId]);
  }

  Future<List<SellingModel>> readSellingsWHEREisReceivedANDRangeDate(
      String selectedTabbar, String fromDate, String toDate, int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.orderedDate} DESC';

    final result = await db.rawQuery(
        "SELECT * FROM selling WHERE ${SellingFields.shopId} = ${shopId} AND ${SellingFields.isDelivered} = 1 AND ${SellingFields.orderedDate} BETWEEN date('${DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate))}') AND date('${DateFormat('yyyy-MM-dd').format(DateTime.parse(toDate))}') ORDER BY ${orderBy}");

    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  // Product lot
  Future<List<SellingModel>> readSellingsWHEREisReceivedANDToday(
      int shopId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM selling WHERE ${SellingFields.shopId} = ${shopId} AND ${SellingFields.isDelivered} = 1 AND ${SellingFields.orderedDate} = date('${DateFormat('yyyy-MM-dd').format(DateTime.now())}')");
    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  // Purchasing
  Future<List<PurchasingModel>> readPurchasingsWHEREisReceivedANDToday(
      int shopId) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM purchasing WHERE ${PurchasingFields.shopId} = ${shopId} AND ${PurchasingFields.isReceive} = 1 AND ${PurchasingFields.orderedDate} = date('${DateFormat('yyyy-MM-dd').format(DateTime.now())}')");
    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readPurchasingsWHEREisReceivedANDRangeDate(
      String selectedTabbar, String fromDate, String toDate, int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.orderedDate} DESC';

    final result = await db.rawQuery(
        "SELECT * FROM purchasing WHERE ${PurchasingFields.shopId} = ${shopId} AND ${PurchasingFields.isReceive} = 1 AND ${PurchasingFields.orderedDate} BETWEEN date('${DateFormat('yyyy-MM-dd').format(DateTime.parse(fromDate))}') AND date('${DateFormat('yyyy-MM-dd').format(DateTime.parse(toDate))}') ORDER BY ${orderBy}");

    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readAllPurchasingsWHEREisNotReceived(
      int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.purId} DESC';
    final result = await db.query(tablePurchasing,
        columns: PurchasingFields.values,
        where:
            '${PurchasingFields.shopId} = ? and ${PurchasingFields.isReceive} = ?',
        whereArgs: [shopId, 0],
        orderBy: orderBy);
    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readAllPurchasingsWHEREisReceived(
      int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.purId} DESC';
    final result = await db.query(tablePurchasing,
        columns: PurchasingFields.values,
        where:
            '${PurchasingFields.shopId} = ? and ${PurchasingFields.isReceive} = ?',
        whereArgs: [shopId, 1],
        orderBy: orderBy);

    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readAllPurchasings(int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.purId} DESC';
    final result = await db.query(tablePurchasing,
        columns: PurchasingFields.values,
        where: '${PurchasingFields.shopId} = ?',
        whereArgs: [shopId],
        orderBy: orderBy);

    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readAllPurchasingsORDERBYPresent(
      int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.orderedDate} DESC';
    final result = await db.query(tablePurchasing,
        columns: PurchasingFields.values,
        where: '${PurchasingFields.shopId} = ?',
        whereArgs: [shopId],
        orderBy: orderBy);

    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readAllPurchasingsORDERBYPresentForGraph(
      int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.orderedDate} DESC';
    final result = await db.query(tablePurchasing,
        columns: PurchasingFields.values,
        where:
            '${PurchasingFields.shopId} = ? and ${PurchasingFields.isReceive} = ?',
        whereArgs: [shopId, 1],
        orderBy: orderBy);

    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readAllPurchasingisReceived(int shopId) async {
    final db = await instance.database;

    final result = await db.rawQuery(
        "SELECT * FROM $tablePurchasing WHERE ${PurchasingFields.isReceive} IS TRUE");

    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<List<PurchasingModel>> readAllPurchasingsByDealerName(
      int shopId, name) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM purchasing INNER JOIN dealer ON dealer._dealerId == purchasing.dealerId WHERE purchasing.shopId == ${shopId} AND dealer.dName LIKE '${name}%' OR dealer.dPhone LIKE '${name}%'");

    return result.map((json) => PurchasingModel.fromJson(json)).toList();
  }

  Future<PurchasingModel> createPurchasing(PurchasingModel pur) async {
    final db = await instance.database;
    final id = await db.insert(tablePurchasing, pur.toJson());
    return pur.copy(purId: id);
  }

  Future<int> updatePurchasing(PurchasingModel pur) async {
    final db = await instance.database;
    return db.update(tablePurchasing, pur.toJson(),
        where: '${PurchasingFields.purId} = ?', whereArgs: [pur.purId]);
  }

  Future<int> deletePurchasing(int purId) async {
    final db = await instance.database;
    return db.delete(tablePurchasing,
        where: '${PurchasingFields.purId} = ?', whereArgs: [purId]);
  }

  // PurchasingItems
  Future<List<PurchasingItemsModel>> readAllPurchasingitems() async {
    final db = await instance.database;
    final orderBy = '${PurchasingItemsFields.purItemsId} ASC';
    final result = await db.query(tablePurchasingItems, orderBy: orderBy);
    return result.map((json) => PurchasingItemsModel.fromJson(json)).toList();
  }

  Future<List<PurchasingItemsModel>> readAllPurchasingItemsWherePurID(
      int id) async {
    final db = await instance.database;
    final orderBy = '${PurchasingItemsFields.purId} DESC';
    final result = await db.query(tablePurchasingItems,
        columns: PurchasingItemsFields.values,
        where: '${PurchasingItemsFields.purId} = ?',
        whereArgs: [id],
        orderBy: orderBy);

    return result.map((json) => PurchasingItemsModel.fromJson(json)).toList();
  }

  Future<PurchasingItemsModel> createPurchasingItem(
      PurchasingItemsModel purItem) async {
    final db = await instance.database;
    final id = await db.insert(tablePurchasingItems, purItem.toJson());
    return purItem.copy(purItemsId: id);
  }

  Future<int> updatePurchasingItem(PurchasingItemsModel purItem) async {
    final db = await instance.database;
    return db.update(tablePurchasingItems, purItem.toJson(),
        where: '${PurchasingItemsFields.purItemsId} = ?',
        whereArgs: [purItem.purItemsId]);
  }

  Future<int> deletePurchasingItem(int purItemId) async {
    final db = await instance.database;
    return db.delete(tablePurchasingItems,
        where: '${PurchasingItemsFields.purItemsId} = ?',
        whereArgs: [purItemId]);
  }
  // PurchasingItems

  // Dealers
  Future<List<DealerModel>> readAllDealers(int shopId) async {
    final db = await instance.database;
    final orderBy = '${DealerFields.dealerId} DESC';
    final result = await db.query(tableDealer,
        columns: DealerFields.values,
        where: '${DealerFields.shopId} = ?',
        whereArgs: [shopId],
        orderBy: orderBy);

    return result.map((json) => DealerModel.fromJson(json)).toList();
  }

  Future<DealerModel> createDealer(DealerModel dealer) async {
    final db = await instance.database;
    final id = await db.insert(tableDealer, dealer.toJson());
    return dealer.copy(dealerId: id);
  }

  Future<int> updateDealer(DealerModel dealer) async {
    final db = await instance.database;
    return db.update(tableDealer, dealer.toJson(),
        where: '${DealerFields.dealerId} = ?', whereArgs: [dealer.dealerId]);
  }

  Future<int> deleteDealer(int dealerId) async {
    final db = await instance.database;
    return db.delete(tableDealer,
        where: '${DealerFields.dealerId} = ?', whereArgs: [dealerId]);
  }
  // Dealers

  // Selling (1.1-1.4)
  // 1.1 Selling
  Future<List<SellingModel>> readAllSellings(int shopId) async {
    final db = await instance.database;
    final orderBy = '${SellingFields.selId} DESC';
    final result = await db.query(tableSelling,
        columns: SellingFields.values,
        where: '${SellingFields.shopId} = ?',
        whereArgs: [shopId],
        orderBy: orderBy);
    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  Future<List<SellingModel>> readAllSellingByCusName(int shopId, name) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM selling INNER JOIN customer ON customer._cusId == selling.customerId INNER JOIN customerAddress ON customer._cusId == customerAddress.cusId WHERE selling.shopId == ${shopId} AND customer.cName LIKE '${name}%' OR customerAddress.cPhone LIKE '${name}%'");

    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  Future<List<SellingModel>> readAlSellingsORDERBYPresent(int shopId) async {
    final db = await instance.database;
    final orderBy = '${SellingFields.orderedDate} DESC';
    final result = await db.query(tableSelling,
        columns: SellingFields.values,
        where: '${SellingFields.shopId} = ?',
        whereArgs: [shopId],
        orderBy: orderBy);

    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  Future<SellingModel> createSelling(SellingModel selling) async {
    final db = await instance.database;
    final id = await db.insert(tableSelling, selling.toJson());
    return selling.copy(selId: id);
  }

  Future<int> updateSelling(SellingModel selling) async {
    final db = await instance.database;
    return db.update(tableSelling, selling.toJson(),
        where: '${SellingFields.selId} = ?', whereArgs: [selling.selId]);
  }

  Future<int> deleteSelling(int selId) async {
    final db = await instance.database;
    return db.delete(tableSelling,
        where: '${SellingFields.selId} = ?', whereArgs: [selId]);
  }

  Future<List<SellingModel>> readAllSellingsWHEREisNotDelivered(
      int shopId) async {
    final db = await instance.database;
    final orderBy = '${SellingFields.selId} DESC';
    final result = await db.query(tableSelling,
        columns: SellingFields.values,
        where:
            '${SellingFields.shopId} = ? and ${SellingFields.isDelivered} = ?',
        whereArgs: [shopId, 0],
        orderBy: orderBy);

    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  Future<List<SellingModel>> readAllSellingsWHEREisDelivered(int shopId) async {
    final db = await instance.database;
    final orderBy = '${SellingFields.selId} DESC';
    final result = await db.query(tableSelling,
        columns: SellingFields.values,
        where:
            '${SellingFields.shopId} = ? and ${SellingFields.isDelivered} = ?',
        whereArgs: [shopId, 1],
        orderBy: orderBy);

    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  Future<List<SellingModel>> readAllSellingsORDERBYPresentForGraph(
      int shopId) async {
    final db = await instance.database;
    final orderBy = '${PurchasingFields.orderedDate} DESC';
    final result = await db.query(tableSelling,
        columns: SellingFields.values,
        where:
            '${SellingFields.shopId} = ? and ${SellingFields.isDelivered} = ?',
        whereArgs: [shopId, 1],
        orderBy: orderBy);

    return result.map((json) => SellingModel.fromJson(json)).toList();
  }

  // 1.1 Selling
  Future<List<SellingItemModel>> readAllSellingItemsWhereSellID(int id) async {
    final db = await instance.database;
    final orderBy = '${SellingItemFields.selId} DESC';
    final result = await db.query(tableSellingItem,
        columns: SellingItemFields.values,
        where: '${SellingItemFields.selId} = ?',
        whereArgs: [id],
        orderBy: orderBy);

    return result.map((json) => SellingItemModel.fromJson(json)).toList();
  }

  // 1.2 Selling Items
  Future<List<SellingItemModel>> readAllSellingItems() async {
    final db = await instance.database;
    final orderBy = '${SellingItemFields.selItemId} DESC';
    final result = await db.query(tableSellingItem, orderBy: orderBy);

    return result.map((json) => SellingItemModel.fromJson(json)).toList();
  }

  Future<SellingItemModel> createSellingItem(SellingItemModel item) async {
    final db = await instance.database;
    final id = await db.insert(tableSellingItem, item.toJson());
    return item.copy(selItemId: id);
  }

  Future<int> deleteSellingItem(int selId) async {
    final db = await instance.database;
    return db.delete(tableSellingItem,
        where: '${SellingItemFields.selId} = ?', whereArgs: [selId]);
  }
  // 1.2 Selling Items

  // 1.3 Customer

  Future<List<CustomerModel>> readAllCustomers() async {
    final db = await instance.database;
    final orderBy = '${CustomerFields.cusId} DESC';
    final result = await db.query(tableCustomer, orderBy: orderBy);

    return result.map((json) => CustomerModel.fromJson(json)).toList();
  }

  Future<List<CustomerModel>> readAllCustomerByCusName(int shopId, name) async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT * FROM customer INNER JOIN customerAddress ON customer._cusId == customerAddress.cusId WHERE customer.shopId == ${shopId} AND customer.cName LIKE '${name}%' OR customerAddress.cPhone LIKE '${name}%'");

    return result.map((json) => CustomerModel.fromJson(json)).toList();
  }

  Future<CustomerModel> readCustomer(int customerId) async {
    final db = await instance.database;
    final orderBy = '${CustomerFields.cusId} DESC';
    final maps = await db.query(tableCustomer,
        whereArgs: [customerId],
        where: '${CustomerFields.cusId} = ?',
        orderBy: orderBy);

    return CustomerModel.fromJson(maps.first);
  }

  Future<List<CustomerModel>> readAllCustomerInShop(int shopId) async {
    final db = await instance.database;
    final orderBy = '${CustomerFields.cusId} DESC';
    final result = await db.query(tableCustomer,
        columns: CustomerFields.values,
        where: '${CustomerFields.shopId} = ?',
        orderBy: orderBy,
        whereArgs: [shopId]);

    return result.map((json) => CustomerModel.fromJson(json)).toList();
  }

  Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final db = await instance.database;
    final id = await db.insert(tableCustomer, customer.toJson());
    return customer.copy(dealerId: id);
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    final db = await instance.database;
    return db.update(tableCustomer, customer.toJson(),
        where: '${CustomerFields.cusId} = ?', whereArgs: [customer.cusId]);
  }

  Future<int> deleteCustomer(int cusId) async {
    final db = await instance.database;
    return db.delete(tableCustomer,
        where: '${CustomerFields.cusId} = ?', whereArgs: [cusId]);
  }

  // 1.3 Customer

  // 1.4 Customer Address
  Future<List<CustomerAddressModel>> readCustomerAddressWHERECustomer(
      int cusAddressId) async {
    final db = await instance.database;

    final result = await db.query(tableCustomerAddress,
        columns: CustomerAddressFields.values,
        where: '${CustomerAddressFields.cAddreId} = ?',
        whereArgs: [cusAddressId],
        limit: 1);
    print(result);

    return result.map((json) => CustomerAddressModel.fromJson(json)).toList();
  }

  Future<List<CustomerAddressModel>> readAllCustomerAddresses() async {
    final db = await instance.database;
    final orderBy = '${CustomerAddressFields.cusId} DESC';
    final result = await db.query(tableCustomerAddress, orderBy: orderBy);

    return result.map((json) => CustomerAddressModel.fromJson(json)).toList();
  }

  Future<List<CustomerAddressModel>> readCustomerAllAddress(int cusId) async {
    final db = await instance.database;
    final orderBy = '${CustomerAddressFields.cusId} DESC';
    final result = await db.query(tableCustomerAddress,
        columns: CustomerAddressFields.values,
        where: '${CustomerAddressFields.cusId} = ?',
        whereArgs: [cusId],
        orderBy: orderBy);

    return result.map((json) => CustomerAddressModel.fromJson(json)).toList();
  }

  Future<CustomerAddressModel> createCustomerAddress(
      CustomerAddressModel address) async {
    final db = await instance.database;
    final id = await db.insert(tableCustomerAddress, address.toJson());
    return address.copy(addreId: id);
  }

  Future<int> updateCustomerAddress(CustomerAddressModel address) async {
    final db = await instance.database;
    return db.update(tableCustomerAddress, address.toJson(),
        where: '${CustomerAddressFields.cAddreId} = ?',
        whereArgs: [address.cAddreId]);
  }

  Future<int> deleteCustomerAddress(int cAddreId) async {
    final db = await instance.database;
    return db.delete(tableCustomerAddress,
        where: '${CustomerAddressFields.cAddreId} = ?', whereArgs: [cAddreId]);
  }

  // 1.4 Customer Address
  // New
  // DeliveryCompany
  Future<List<DeliveryCompanyModel>> readDeliveryCompanys(int shopId) async {
    final db = await instance.database;
    final orderBy = '${DeliveryCompanyFields.dcId} DESC';
    final result = await db.query(tableDeliveryCompany,
        columns: DeliveryCompanyFields.values,
        where: '${DeliveryCompanyFields.shopId} = ?',
        whereArgs: [shopId],
        orderBy: orderBy);

    return result.map((json) => DeliveryCompanyModel.fromJson(json)).toList();
  }

  Future<DeliveryCompanyModel> readDeliveryCompanysOnlyOne(int id) async {
    final db = await instance.database;
    final maps = await db.query(tableDeliveryCompany,
        columns: DeliveryCompanyFields.values,
        where: '${DeliveryCompanyFields.dcId} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return DeliveryCompanyModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<DeliveryCompanyModel> createDeliveryCompany(
      DeliveryCompanyModel company) async {
    final db = await instance.database;
    final id = await db.insert(tableDeliveryCompany, company.toJson());
    return company.copy(dcId: id);
  }

  Future<int> updateDeliveryCompany(DeliveryCompanyModel company) async {
    final db = await instance.database;
    return db.update(tableDeliveryCompany, company.toJson(),
        where: '${DeliveryCompanyFields.dcId} = ?', whereArgs: [company.dcId]);
  }

  Future<int> deleteDeliveryCompany(int dcId) async {
    final db = await instance.database;
    return db.delete(tableDeliveryCompany,
        where: '${DeliveryCompanyFields.dcId} = ?', whereArgs: [dcId]);
  }

  // Delivery Rates
  Future<List<DeliveryRateModel>> readDeliveryRatesWHEREdcId(int dcId) async {
    final db = await instance.database;
    final orderBy = '${DeliveryRateFields.dcId} DESC';
    final result = await db.query(tableDeliveryRate,
        columns: DeliveryRateFields.values,
        where: '${DeliveryRateFields.dcId} = ?',
        whereArgs: [dcId],
        orderBy: orderBy);

    return result.map((json) => DeliveryRateModel.fromJson(json)).toList();
  }

  Future<DeliveryRateModel> createDeliveryRate(DeliveryRateModel rate) async {
    final db = await instance.database;
    final id = await db.insert(tableDeliveryRate, rate.toJson());
    return rate.copy(rId: id);
  }

  Future<int> updateDeliveryRate(DeliveryRateModel rate) async {
    final db = await instance.database;
    return db.update(tableDeliveryRate, rate.toJson(),
        where: '${DeliveryRateFields.rId} = ?', whereArgs: [rate.rId]);
  }

  Future<int> deleteDeliveryRate(int rId) async {
    final db = await instance.database;
    return db.delete(tableDeliveryRate,
        where: '${DeliveryRateFields.rId} = ?', whereArgs: [rId]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
