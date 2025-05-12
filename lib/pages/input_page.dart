import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tallysheet_app/services/firestore.dart';
import 'package:tallysheet_app/util/detail_adapter.dart';
import 'package:tallysheet_app/util/input_adapter.dart';
import 'package:tallysheet_app/util/show_detail.dart';

// ignore: must_be_immutable
class InputPage extends StatefulWidget {
  final String? idShipment;
  final String? selectedItem;
  final String? contTruck;
  final String? item;
  // List<QueryDocumentSnapshot> data;
  Map<String, Map<String, dynamic>> docDataTally;
  InputPage({super.key, required this.idShipment, required this.selectedItem, required this.contTruck, required this.docDataTally, required this.item});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final RealTimeDatabaseService fireStoreService = RealTimeDatabaseService();
  final TextEditingController _countController = TextEditingController();

  String? item;
  String? truck;
  String? selItem;
  String? idShipment;
  String? customer;
  String? itemValue;
  String? itemInfor;

  String? _selectedColor;
  final List<String> _dropdownColors = [];

  List<InputAdapter> inputDataList = [];
  Map<String,Map<String, dynamic>> docDataMap = {};

  List<DetailAdapter> detailDataList = [];

  String? infor;
  String? counted;

  int selectedIndex = -1;
  String? selectedItem;

  @override
  void initState(){
    super.initState();
    idShipment = widget.idShipment;    
    truck = widget.contTruck;
    docDataMap = widget.docDataTally;
    selItem = widget.item;
    itemValue = widget.selectedItem;

    customer = idShipment!.substring(0, 4);
    var id = idShipment!.substring(idShipment!.length - 4);
  
    if (customer == 'MUJI' && (selItem == 'BUYER_PO' || selItem == 'CT_NO')){
      item = itemValue!.substring(8);
      itemInfor = "${itemValue!.substring(0,5)} / $item";
    }else{
      item = itemValue;
      itemInfor = item;
    }
    infor = "ID:$id / $itemInfor";
    _selectedColor = null;

    getColor();

  }

  Future<void> getColor() async {
    if (docDataMap.isNotEmpty){
      Set<String> uniqueColor = {};

      uniqueColor.add("All colors");
      for (var doc in docDataMap.entries){
        var docData = doc.value;

        if (docData.containsKey("COLOR") && docData['ID_SHIPMENT'] == idShipment){
          if (docData[selItem] == item){
            uniqueColor.add(docData['COLOR']);
          }
        }
      }
      
      setState(() {
        _dropdownColors.addAll(uniqueColor);
      });
    }
  }

  Future<void> clickQuery() async {

    if (docDataMap.isNotEmpty){
      Map<String, Map<String, dynamic>> itemData = {};
      String? selectItem;

      inputDataList = [];

      for (var docEntry in docDataMap.entries){
        var docData = docEntry.value;

        void processItemData(){
          if (docData.containsKey('Tallysheet') && docData['Tallysheet'] != 0) {
            itemData[selectItem]!['totalTallysheet'] += (docData['Tallysheet'] as num).toInt();
          }

          if (docData.containsKey('UCC') && docData['UCC'] != '') {
            itemData[selectItem]!['uniqueUCC'].add(docData['UCC']);
          }
          if (docData.containsKey('Scanned')) {
            if (docData['Scanned'] != "") {
              itemData[selectItem]!['uniqueScanned'].add(docData['Scanned']);
            }
          }
        }

        if (docData.containsKey(selItem) && docData[selItem] == item && docData['ID_SHIPMENT'] == idShipment) {
          if (_selectedColor != null){
            if (_selectedColor == "All colors"){
              selectItem = docData['COLOR'] as String?;
            } else{
              if (docData.containsKey("COLOR") && docData["COLOR"] == _selectedColor){
                selectItem = docData['SIZE'] as String?;
              }else{
                // Nếu COLOR không khớp thì bỏ qua bản ghi này
                continue;
              }
            }
            
            
          } else {
            selectItem = docData[selItem] as String?;
          }

          if (selectItem != null) {
            if (!itemData.containsKey(selectItem)) {
              itemData[selectItem] = {
                'uniqueScanned': <String>{},
                'totalTallysheet': 0,
                'uniqueUCC': <String>{},
              };
            }
            processItemData();
          }
        }

      }
      
      for (var entry in itemData.entries) {
        int uniqueUCC = entry.value['uniqueUCC'].length;
        int scanned = entry.value['uniqueScanned'].length;
        int count = entry.value['totalTallysheet'];

        int notScan = scanned - uniqueUCC;
        int notCount = count - uniqueUCC;

        inputDataList.add(InputAdapter(
          entry.key,
          uniqueUCC,
          notScan,
          notCount,
        ));
      }

      setState(() {});

    }
    
  }

  Future<void> clickCount() async {
    final String countCtn = _countController.text.trim();

    if (countCtn.isNotEmpty) {
      int count = int.parse(countCtn);

      Map<String, int> sttMap = {}; // Lưu trữ giá trị STT của các tài liệu
      Map<String, int> soDemMap = {}; // Lưu trữ giá trị So_dem của các tài liệu

      Map<String, int> tallySheetMap = {};
      // Map<String, int> countMap = {};

      Set<String> uccUnique = {};
      int countUcc = 0;

      // Hàm lấy dữ liệu tallysheet
      void getDataTallysheet(docId, docData) {
        if (docData.containsKey(selItem) && docData[selItem] == item && docData['ID_SHIPMENT'] == idShipment){
          int tally = 0;
          
          if (_selectedColor != null) {
            if (docData['COLOR'] == _selectedColor && docData['SIZE'] == selectedItem) {
              tally = docData['Tallysheet'] ?? 0;
              uccUnique.add(docData['UCC']);
              countUcc = uccUnique.length;

              tallySheetMap[docId] = tally;

            } else if (_selectedColor == "All colors" && docData['COLOR'] == selectedItem) {
              tally = docData['Tallysheet'] ?? 0;

              uccUnique.add(docData['UCC']);
              countUcc = uccUnique.length;

              tallySheetMap[docId] = tally;
            }
          } else {
            tally = docData['Tallysheet'] ?? 0;

            uccUnique.add(docData['UCC']);
            countUcc = uccUnique.length;

            tallySheetMap[docId] = tally;
            // countMap[docId] = countUcc;
          }
        }
      }

      void getSttCount(docId, docData) {
        if (docData.containsKey(selItem) && docData[selItem] == item && docData['So_dem'] != 0 && docData['ID_SHIPMENT'] == idShipment){
          int stt = docData['STT'] ?? 0;
          int soDem = docData['So_dem'] ?? 0;
          
          if (_selectedColor != null){
            if (_selectedColor == "All colors" && docData['COLOR'] == selectedItem){
              soDemMap[docId] = soDem;
            } else if (docData['COLOR'] == _selectedColor && docData['SIZE'] == selectedItem){
              soDemMap[docId] = soDem;
            }
          } else {
            soDemMap[docId] = soDem;
          }

          sttMap[docId] = stt;
          
        }
        
      }

      void summaryGet (){
        for (var doc in docDataMap.entries){
          var docData = doc.value;
          var docId = doc.key;

          getSttCount(docId, docData);
          getDataTallysheet(docId, docData);
        
        }
      }

      if (docDataMap.isNotEmpty) {
        bool anyMatch = false;

        summaryGet();

        // Kiểm tra tất cả các tài liệu trước khi quyết định có hiển thị dialog hay không
        for (var entry in docDataMap.entries) {
          var docData = entry.value;
          var docId = entry.key;

          if (docData.containsKey(selItem) && docData[selItem] == item && docData['Count_Pallet'] != 0 && docData['ID_SHIPMENT'] == idShipment) {

            getDataTallysheet(docId, docData);

            // Kiểm tra các điều kiện match
            if (docData['Count_Pallet'] == count && docData['Tallysheet'] == 0){
              if (_selectedColor != null) {
                if (_selectedColor == "All colors" && docData['COLOR'] == selectedItem){
                  anyMatch = true;
                  break;
                }
                else if (docData['COLOR'] == _selectedColor && docData['SIZE'] == selectedItem) {
                  anyMatch = true;
                  break;
                }
              } else{
                anyMatch = true;
                break;
              }
            }
            
          }
        }

        // Tính tổng số tallysheet và count
        int totalTallysheet = tallySheetMap.values.fold<int>(0, (a, b) => a + b);
        // int totalCount = countMap.values.fold<int>(0, (a, b) => a + b);
        int totalCount = countUcc;

        // Kiểm tra nếu (totalTallysheet + count) <= totalCount
        if ((totalTallysheet + count) <= totalCount) {
          if (!anyMatch) {
            bool shouldUpdate = false;
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Xác nhận"),
                  content: Text("$countCtn thùng này không nằm trong bản scan, có đếm không?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        shouldUpdate = true;
                        Navigator.of(context).pop();
                      },
                      child: const Text("Xác nhận"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Bỏ qua"),
                    ),
                  ],
                );
              },
            );

            if (shouldUpdate) {
              // Cập nhật Firestore nếu người dùng xác nhận
              for (var entry in docDataMap.entries) {
                var docData = entry.value;
                var docId = entry.key;

                if (docData.containsKey(selItem) && docData[selItem] == item && docData['Count_Pallet'] == 0 && docData['Tallysheet'] == 0) {
                  if (_selectedColor != null) {
                    if (_selectedColor == "All colors" && docData['COLOR'] == selectedItem) {
                      await updateData(docId, docData, sttMap, soDemMap, totalTallysheet);
                      break;
                    } else if (docData['COLOR'] == _selectedColor && docData['SIZE'] == selectedItem) {
                      await updateData(docId, docData, sttMap, soDemMap, totalTallysheet);
                      break;
                    }
                  } else {
                    await updateData(docId, docData, sttMap, soDemMap, totalTallysheet);
                    break;
                  }
                }
              }
              await clickQuery();
            }
          } else {
            // Nếu có tài liệu match, cập nhật trực tiếp
            for (var entry in docDataMap.entries) {
              var docData = entry.value;
              var docId = entry.key;

              bool shouldUpdate = false;
              if (docData.containsKey(selItem) && docData[selItem] == item && docData['Count_Pallet'] != 0) {
                if (_selectedColor != null) {
                  if (docData['COLOR'] == _selectedColor && docData['SIZE'] == selectedItem && docData['Count_Pallet'] == count && docData['Tallysheet'] == 0) {
                    shouldUpdate = true;
                  } else if (_selectedColor == 'All colors' && docData['COLOR'] == selectedItem){
                    shouldUpdate = true;
                  }
                } else if (docData['Count_Pallet'] == count && docData['Tallysheet'] == 0) {
                  shouldUpdate = true;
                }
              }

              if (shouldUpdate) {
                await updateData(docId, docData, sttMap, soDemMap, totalTallysheet);
                break;
              }
            }
          }

        } else {
          int diff = (totalTallysheet + count) - totalCount;
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Cảnh báo"),
                content: Text("Tổng số lượng đếm đang thừa $diff thùng, kiểm tra lại"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Đóng"),
                  ),
                ],
              );
            },
          );
        }

        // Cuối cùng, gọi hàm clickQuery
        await clickQuery();
      }
      _countController.text = "";
    } else {
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Cảnh báo"),
            content: const Text("Chưa nhập số lượng đếm hàng"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Đóng"),
              ),
            ],
          );
        },
      );
    }
  }

  // Hàm cập nhật Firestore
  Future<void> updateData(String docId, Map<String, dynamic> docData, Map<String, int> sttMap, Map<String, int> soDemMap, int totalTallysheet) async {
    int maxSoDem = soDemMap.values.fold<int>(0, (a, b) => a > b ? a : b); // Lấy giá trị So_dem lớn nhất
    int newSoDem = maxSoDem + 1;

    int maxSTT = sttMap.values.fold<int>(0, (a, b) => a > b ? a : b);
    int stt = maxSTT == 0 ? 1 : 0; // Nếu maxSTT == 0 thì stt = 1, ngược lại stt = 0

    int count = int.parse(_countController.text);

    int totalCounted = totalTallysheet + count;
    await fireStoreService.updateNotesBasedOnCondition(
      "shipment",
      idShipment!,
      docId,
      truck!,
      newSoDem,
      stt,
      int.parse(_countController.text),
    );

    // Cập nhật docDataMap sau khi đã cập nhật Firestore
    docData['Cont_Truck'] = truck;
    docData['So_dem'] = newSoDem;
    docData['Tallysheet'] = count;
    docData['STT'] = stt;

    counted = '($totalCounted)';
  }

  Future<void> clickDetail() async {
    await showDetail();
    showDialog(
      // ignore: use_build_context_synchronously
      context: context, 
      builder: (context) {
        return ShowDetail(listData: detailDataList, idShipment: idShipment, docDataMap: docDataMap,);
      }
    );
  }

  Future<void> showDetail() async {
    if (docDataMap.isNotEmpty){
      Map<String, Map<String, dynamic>> itemData = {};
      String? selectItem;

      detailDataList = [];

      for (var docEntry in docDataMap.entries){
        var docData = docEntry.value;
        var docId = docEntry.key;

        void processItemData(){

          if (docData.containsKey('Tallysheet')) {
            if (docData['Tallysheet'] != 0){
              itemData[selectItem]!['tallySheet'] += (docData['Tallysheet'] as num).toInt();
            }
          }
          if (docData.containsKey('Count_Pallet') && selectItem != null) {
            itemData[selectItem]!['countPallet'] += (docData['Count_Pallet'] as num).toInt();
          }

          // (itemData[selectItem]!['docIds'] as List<String>).add(docId);
          itemData[selectItem]!['docIds'] += (itemData[selectItem]!['docIds'].isNotEmpty
            ? ", $docId"
            : docId);
          
        }

        if (docData.containsKey(selItem) && docData[selItem] == item && docData['ID_SHIPMENT'] == idShipment && docData['So_dem'] != 0) {
          if (_selectedColor != null){
            if (_selectedColor == "All colors" && docData['COLOR'] == selectedItem){
              selectItem = docData['So_dem'].toString();
            } else{
              if (docData.containsKey("COLOR") && docData["COLOR"] == _selectedColor && docData['SIZE'] == selectedItem){
                selectItem = docData['So_dem'].toString();
              }else{
                // Nếu COLOR không khớp thì bỏ qua bản ghi này
                continue;
              }
            }
            
          } else {
            selectItem = docData['So_dem'].toString();
          }


          if (!itemData.containsKey(selectItem)) {
            itemData[selectItem] = {
              'countPallet': 0,
              'tallySheet': 0,
              'docIds': '',
            };
          }
          processItemData();
        }

      }
      
      for (var entry in itemData.entries) {
        int count = entry.value['countPallet'];
        int tally = entry.value['tallySheet'];
        String docIds = entry.value['docIds'];

        detailDataList.add(DetailAdapter(
          entry.key,
          tally,
          count,
          docIds
        ));
      }
      detailDataList.sort((a, b) => int.parse(a.stt).compareTo(int.parse(b.stt)));

    }
  }

  void _navigateBack() {
    Navigator.pop(context, docDataMap); // Trả lại dữ liệu đã cập nhật
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "ĐẾM HÀNG",
          style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            _navigateBack();
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 136, 232, 237),
          ),
          icon: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back, color: Colors.deepOrange),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(infor??'', style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.redAccent))
              ],
            ),
            const SizedBox(height: 15,),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text(
                        'Chọn màu',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      value: _selectedColor,
                      items: _dropdownColors.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedColor = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10,),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {
                      clickQuery();
                    },
                    child: const Text('QUERY'),
                  ),
                ),
              ],
            ),
        
            const SizedBox(height: 15,),
        
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _countController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      hintText: 'Số lượng',
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5))
                    )
                  )
                ),
                const SizedBox(width: 5,),
                Text(counted??'', style: const TextStyle(fontSize: 12, color: Colors.blueAccent),),
                const SizedBox(width: 5,),
                Expanded(
                      child: ElevatedButton(
                        onPressed: (){
                          clickCount();
                        },
                        child: const Text('ĐẾM HÀNG', textAlign: TextAlign.center,),
                      )
                  ),
                  const SizedBox(width: 5,),
                  
                  Expanded(
                      child: ElevatedButton(
                        onPressed: (){
                          clickDetail();
                        },
                        child: const Text('CHI TIẾT', textAlign: TextAlign.center),
                      )
                  ),
              ],
            ),
            const SizedBox(height: 15,),
              
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(flex: 2,child: Text('TÊN HÀNG', textAlign: TextAlign.center,)),
                Expanded(flex: 1,child: Text('THÙNG', textAlign: TextAlign.center)),
                Expanded(flex: 1,child: Text('SCAN', textAlign: TextAlign.center)),
                Expanded(flex: 1,child: Text('ĐẾM', textAlign: TextAlign.center))
              ],
            ),
            const SizedBox(height: 15,),
        
            Expanded(
              child: ListView.builder(
                itemCount: inputDataList.length,
                itemBuilder: (context, index) {
                  final data = inputDataList[index];
                  bool isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedIndex = index;
                      });
                      selectedItem = data.item;
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  color: isSelected ? Colors.blue[200] : Colors.transparent,
                                  child: Text(data.item, textAlign: TextAlign.center),
                                ),
                                
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                color: isSelected ? Colors.blue[200] : Colors.transparent,
                                child: Text('${data.ctn}', textAlign: TextAlign.center),
                              ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                color: isSelected ? Colors.blue[200] : Colors.transparent,
                                child: Text('${data.scanned}', textAlign: TextAlign.center),
                              ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                color: isSelected ? Colors.blue[200] : Colors.transparent,
                                child: Text('${data.counted}', textAlign: TextAlign.center),
                              ),
                              )
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, color: Color.fromARGB(255, 251, 235, 235),)
                      ],
                    ),
                  );
                },
              ),
            )
        
          ],
        ),
      ),
    );
  }
}