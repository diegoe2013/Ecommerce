import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/Controllers/databaseHelper.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({super.key});

  @override
  _PaymentMethods createState() => _PaymentMethods();
}

class _PaymentMethods extends State<PaymentMethods> {
  final userId = "1";
  late List<Map<String, dynamic>> cardsMap;
  final DBHelper dbHelper = DBHelper();

  late String autoincrementIndex ;

  int selectedCard = 0;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
    
  @override
  void initState() {
    super.initState();
    getAutoIncrementIndex(); 
  }

  void getAutoIncrementIndex() async {
    // autoincrement es parte de un future por lo que hay que correrlo dentro de una funcion con async
    autoincrementIndex = await dbHelper.autoIncrement('paymentMethods');
  }

  void updateSelectedCard(Map<String, dynamic> newCard) {
    setState(() {
      selectedCard = int.parse(newCard['id']) - 1;
    });

    dbHelper.updateData("users/$userId", {
      'paymentMethods.id': newCard['id'],
      'paymentMethods.holderName': newCard['holderName'],
      'paymentMethods.cardNumber': newCard['cardNumber'],
      'paymentMethods.expiryDate': newCard['expiryDate'],
      'paymentMethods.type': newCard['type'],
    });

    setState(() {
      selectedCard = 0;
    });
  }

  void createCard() {
    dbHelper.addData("paymentMethods/$autoincrementIndex", {
      'id': autoincrementIndex,
      'holderName': _nameController.text,
      'cardNumber': _numberController.text,
      'userId': userId,
      'type': _typeController.text,
      'expiryDate': _expiryDateController.text
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment methods'),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Column(
          children: [
            dbHelper.getData(
                path: 'users',
                columnFilter: 'id',
                filterValue: userId.toString(),
                itemBuilder: (users) {
                  var user = users[0];
                  var paymentCard =
                      user['paymentMethods'] as Map<String, dynamic>;

                  return Expanded(
                    child: dbHelper.getData(
                        path: 'paymentMethods',
                        columnFilter: 'userId',
                        filterValue: userId.toString(),
                        itemBuilder: (cards) {
                          var paymentCards = [paymentCard];

                          print(paymentCard);

                          for (int i = 0; i < cards.length; i++) {
                            print(cards[i]["id"] != paymentCard["id"]);
                            if (cards[i]["id"] != paymentCard["id"]) {
                              paymentCards.add(cards[i]);
                            }
                          }

                          print(paymentCards);

                          cardsMap = paymentCards;
                          getAutoIncrementIndex();
                          // autoincrementIndex = await dbHelper.autoIncrement('paymentMethods');

                          return ListView.builder(
                            itemCount: paymentCards.length,
                            itemBuilder: (context, index) {
                              return PaymentCard(
                                paymentCard: paymentCards[index],
                                chosen: (index == selectedCard),
                                onSelected: () =>
                                    updateSelectedCard(paymentCards[index]),
                              );
                            },
                          );
                        }),
                  );
                }),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/plus.svg',
                  width: 40,
                  height: 40,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text(
                                    'Add New Card',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Card Holder Name'),
                                  controller: _nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the card holder name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Card Number'),
                                  controller: _numberController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the card number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Expiry Date (MM/YY)'),
                                  controller: _expiryDateController,
                                  keyboardType: TextInputType.datetime,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the expiry date';
                                    }
                                    return null;
                                  },
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                      labelText: 'Card Type'),
                                  controller: _typeController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the card type';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      createCard();
                                      Navigator.of(context).pop();
                                    }
                                  },
                                  child: const Text('Save'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentCard extends StatefulWidget {
  final Map<String, dynamic> paymentCard;
  final bool chosen;
  final VoidCallback onSelected;

  const PaymentCard(
      {super.key,
      required this.paymentCard,
      required this.chosen,
      required this.onSelected});

  @override
  _PaymentCard createState() => _PaymentCard();
}

class _PaymentCard extends State<PaymentCard> {
  late bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          color: const Color.fromARGB(255, 47, 46, 46),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: SvgPicture.asset(
                    'assets/icons/cards/${widget.paymentCard["type"]}.svg',
                    width: 60,
                    height: 50,
                  ),
                ),
                Text(
                  "**** **** **** ${widget.paymentCard['cardNumber'].toString().substring(12)}",
                  style: const TextStyle(
                      fontSize: 22, color: Colors.white, letterSpacing: 3),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: SvgPicture.asset(
                    'assets/icons/cards/chip.svg',
                    width: 60,
                    height: 40,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Card Holder Name",
                          style: TextStyle(
                              color: Color.fromARGB(255, 230, 230, 230),
                              fontSize: 10),
                        ),
                        Text(
                          widget.paymentCard['holderName'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Expiry Date",
                          style: TextStyle(
                              color: Color.fromARGB(255, 230, 230, 230),
                              fontSize: 10),
                        ),
                        Text(
                          "${widget.paymentCard['expiryDate'].substring(0, 2)}/${widget.paymentCard['expiryDate'].substring(3)}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: widget.chosen,
              onChanged: (bool? newValue) {
                if (newValue == true) {
                  widget.onSelected();
                }
              },
            ),
            const Text("Use as payment method")
          ],
        ),
        const SizedBox(height: 10)
      ],
    );
  }
}