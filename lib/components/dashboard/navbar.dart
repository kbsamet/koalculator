import 'package:flutter/material.dart';
import 'package:koalculator/screens/debt_screens/add_debt.dart';
import 'package:koalculator/screens/debt_screens/debt_history.dart';
import 'package:koalculator/screens/group_screens/create_group.dart';

class BottomNavbar extends StatelessWidget {
  final bool areGroupsEmpty;
  const BottomNavbar({super.key, required this.areGroupsEmpty});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      //bottom navigation bar on scaffold
      color: const Color(0xff303139),
      shape: const CircularNotchedRectangle(), //shape of notch
      notchMargin: 6, //notche margin between floating button and bottom appbar
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          //children inside bottom appbar
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const DebtHistory())),
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.history,
                      size: 30,
                      color: Color.fromARGB(255, 255, 61, 106),
                    ),
                    Text(
                      "Geçmiş",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 61, 106),
                      ),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (areGroupsEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Grup oluşturmadan önce borç ekleyemezsiniz."),
                    ),
                  );
                  return;
                }

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AddDebtScreen()));
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add_card,
                      size: 30,
                      color: Color.fromARGB(255, 255, 61, 106),
                    ),
                    Text(
                      "Borç Ekle",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 61, 106)),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateGroup())),
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.add,
                      size: 30,
                      color: Color.fromARGB(255, 255, 61, 106),
                    ),
                    Text(
                      "Grup Oluştur",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 61, 106)),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              child: Container(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.menu,
                      size: 30,
                      color: Color.fromARGB(255, 255, 61, 106),
                    ),
                    Text(
                      "Ayarlar",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 61, 106)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
