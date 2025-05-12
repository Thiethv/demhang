import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:tallysheet_app/pages/tally_page.dart';
import 'package:tallysheet_app/services/fs_inforvehicle.dart';
import 'package:tallysheet_app/util/dialog_box.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tallysheet_app/util/dialog_box_add_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final vehicle = InforVehicle();

  int _selectedIndex = -1;
  Map<int, Map<String, dynamic>> selectedValues = {}; // Dùng Map để lưu trữ giá trị được chọn

  TextEditingController controllerCont = TextEditingController();
  TextEditingController controllerSeal = TextEditingController();
  TextEditingController controllerDemhang = TextEditingController();
  TextEditingController controllerBaoVe = TextEditingController();
  TextEditingController controllerContLoi = TextEditingController();
  TextEditingController controllerDate = TextEditingController();

  String selectedRadio = 'Cont 40';

  @override
  void initState() {
    super.initState();
    controllerDate.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  void onRadioChanged(String value) {
    setState(() {
      selectedRadio = value;
    });
  }

  void updateContTruck({String? docID}){
    if (_selectedIndex != -1 && selectedValues.containsKey(_selectedIndex)){
      controllerCont.text = selectedValues[_selectedIndex]!['cont']??'';
      controllerSeal.text = selectedValues[_selectedIndex]!['seal']??'';
      controllerDemhang.text = selectedValues[_selectedIndex]!['counter']??'';
      controllerBaoVe.text = selectedValues[_selectedIndex]!['baove']??'';
      controllerContLoi.text = selectedValues[_selectedIndex]!['contloi']??'';
      
    }
    
    controllerDate.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    showDialog(
      context: context, 
      builder: (context) {
        return DialogBox(
          controllerCont: controllerCont,
          controllerSeal: controllerSeal,
          controllerDemhang: controllerDemhang,
          controllerBaoVe: controllerBaoVe,
          controllerContLoi: controllerContLoi,
          controllerDate: controllerDate,

          onSave:() {
            if (docID != null){
              vehicle.updateNote(docID, controllerBaoVe.text, controllerCont.text, 
            controllerContLoi.text, controllerDemhang.text, controllerDate.text, controllerSeal.text);
            Navigator.of(context).pop();
            }
            
          }, 
          onCancel: () => Navigator.of(context).pop()
        );
      }
    );
  }

  void addNewContTruck(){
    controllerDate.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    controllerBaoVe.text = '';
    controllerCont.text = '';
    controllerContLoi.text = '';
    controllerDemhang.text = '';
    controllerSeal.text = '';
    showDialog(
      context: context, 
      builder: (context) {
        return DialogBoxAddNew(
          controllerCont: controllerCont,
          controllerSeal: controllerSeal,
          controllerDemhang: controllerDemhang,
          controllerBaoVe: controllerBaoVe,
          controllerContLoi: controllerContLoi,
          controllerDate: controllerDate,
          onRadioChanged: onRadioChanged,

          onSave:() {
            vehicle.addNote(controllerBaoVe.text, controllerCont.text, controllerContLoi.text,
            controllerDemhang.text, controllerDate.text, controllerSeal.text, selectedRadio);
            Navigator.of(context).pop();
          }, 
          onCancel: () => Navigator.of(context).pop()
        );
      }
    );
  }

  void navigateToTallyPage(){
    if (selectedValues.isNotEmpty){
      String? loaiXe = selectedValues[_selectedIndex]?['type'];
      String? nguoiDem = selectedValues[_selectedIndex]?['counter'];
      if (loaiXe != '' && nguoiDem != ''){
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => TallyPage(selectedIndex: _selectedIndex, selectedValues: selectedValues)
          ),
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa điền đầy đủ thông tin !!!'))
        );
      }
      
    } else{
      showDialog(
        context: context, 
        builder: (context){
          return AlertDialog(
            title: const Text('Thông báo'),
            content: const Text('Chưa chọn xe để đếm hàng'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Đóng'),
              ),
            ],
          );
        }
      );
    }
    
  }

  @override
  Widget build(BuildContext context) {   
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TALLY SHEET",
          style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        actions: <Widget> [
          ElevatedButton(
          onPressed: navigateToTallyPage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[400],
            foregroundColor: Colors.white,
          ),
          child: const Row(
            children: [
              Icon(Icons.arrow_forward, color: Colors.deepOrange,),
              SizedBox(width: 8,),
              Text('Chọn Id',style: TextStyle(fontSize: 14),),
            ],
          ),
        ),
        ],
        
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addNewContTruck,
        child: const Icon(Icons.add),
      ),
      
      body: Column(
        children: [
          const SizedBox(height: 15,),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'LOẠI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'SỐ XE',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'CHÌ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ĐẾM',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              ],
            ),
          ),

          const SizedBox(height: 15,),
          // Hiển thị thông tin lên listview
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: vehicle.getNoteStream(),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                } else if (!snapshot.hasData || snapshot.data!.snapshot.children.isEmpty) {
                  return const Center(child: Text('Không có xe nào!.'));
                } else {
                  List<DataSnapshot> noteList = snapshot.data!.snapshot.children.map((child) => child).toList();
                  return ListView.builder(
                    itemCount: noteList.length,
                    itemBuilder: (context, index) {
                      DataSnapshot  document = noteList[index];
                      // Map<String, dynamic> data = Map<String, dynamic>.from(document.value as Map<String, dynamic>);
                      Map<String, dynamic> data = {};

                      if (document.value != null && document.value is Map) {
                        data = Map<String, dynamic>.from(document.value as Map);
                      }
                      // Lấy các giá trị cụ thể từ doc
                      String type = data['type']??'';
                      String cont = data['cont']??'';
                      String seal = data['seal']??'';
                      String counter = data['counter']??'';

                      String docId = document.key!;

                      return Slidable(
                        key: Key(docId),
                        endActionPane: ActionPane(
                          motion: const StretchMotion(), 
                          children: [
                            SlidableAction(
                              onPressed: (context) => updateContTruck(docID: docId),
                              icon: Icons.update,
                              backgroundColor: Colors.green.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            SlidableAction(
                              onPressed: (context) => vehicle.deleteNote(docId),
                              icon: Icons.delete,
                              backgroundColor: Colors.red.shade300,
                              borderRadius: BorderRadius.circular(10),
                            )
                          ]
                        ),
                        child: Card(
                          color: _selectedIndex == index ? Colors.grey[300] : Colors.white,
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    type,
                                    style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    cont,
                                    style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    seal,
                                    style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    counter,
                                    style: TextStyle(fontWeight: _selectedIndex == index? FontWeight.bold: FontWeight.normal, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ]
                            ),                        
                            onTap: () {
                              setState(() {
                                // Xóa giá trị của lần chọn trước đó nếu có
                                if (_selectedIndex != -1 && selectedValues.containsKey(_selectedIndex)) {
                                  selectedValues.remove(_selectedIndex);
                                }
                                // Cập nhật giá trị mới
                                _selectedIndex = index;
                                selectedValues[index] = {
                                  'type': type,
                                  'cont': cont,
                                  'seal': seal,
                                  'counter': counter,
                                  'baove': data['baove']??'',
                                  'contloi': data['contloi']??''

                                };
                              });
                            },
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
