// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';

Widget wTabHome(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.width / 2,
    decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color.fromARGB(255, 192, 221, 215),
            Color.fromARGB(255, 89, 156, 211),
            Color.fromARGB(255, 160, 172, 177),
          ],
          transform: const GradientRotation(pi / 4),
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
              blurRadius: 4,
              color: Color.fromARGB(255, 243, 242, 242),
              offset: Offset(5, 5))
        ]),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Total Balance',
          style: TextStyle(
              fontSize: 16.0, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(
          height: 12,
        ),
        const Text(
          '\$ 2000.00',
          style: TextStyle(
              fontSize: 40.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                          color: Colors.white30, shape: BoxShape.circle),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_downward,
                          size: 12,
                          color: Colors.greenAccent,
                        ),
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Income',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$ 200.00',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                          color: Colors.white30, shape: BoxShape.circle),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_upward,
                          size: 12,
                          color: Colors.redAccent,
                        ),
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expenses',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$ 400.00',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
  // const SizedBox(
  //   height: 40,
  // ),
  // Row(
  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //   children: [
  //     Text(
  //       'Transactions',
  //       style: TextStyle(
  //           fontSize: 16.0,
  //           color: Theme.of(context).colorScheme.onSurface,
  //           fontWeight: FontWeight.bold),
  //     ),
  //     GestureDetector(
  //       onTap: () {},
  //       child: Text(
  //         'View all',
  //         style: TextStyle(
  //             fontSize: 14.0,
  //             color: Theme.of(context).colorScheme.outline,
  //             fontWeight: FontWeight.w400),
  //       ),
  //     ),
  //   ],
  // );
}
