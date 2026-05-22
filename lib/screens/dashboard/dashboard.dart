import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  final Color bg = const Color(0xFFF5F2EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B6F63),
        elevation: 6,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {},
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(22),

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: 2,

          elevation: 0,

          backgroundColor:
              Colors.transparent,

          selectedItemColor:
              Colors.black,

          unselectedItemColor:
              Colors.black54,

          type:
              BottomNavigationBarType.fixed,

          items: const [

            BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline),
              label: "",
            ),

            BottomNavigationBarItem(
              icon:
                  Icon(Icons.explore_outlined),
              label: "",
            ),

            BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundColor:
                    Color(0xFFD7D7D7),

                child: Icon(
                  Icons.map_outlined,
                  color: Colors.black,
                ),
              ),

              label: "",
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "",
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 28,
          ),

          child: Column(
            children: [

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.topRight,
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_horiz,
                    size: 30,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      AuthService().logout();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/welcome',
                        (route) => false,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully'),
                          backgroundColor: Colors.black87,
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Explore the best Spots",

                style: TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                decoration:
                    InputDecoration(
                  hintText:
                      "Search",

                  filled: true,

                  fillColor:
                      const Color(
                          0xFFEFEFEF),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                30),

                    borderSide:
                        BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: [

                    buildCard(
                      title: "KIT",

                      image:
                          "assets/kit.png",
                    ),

                    const SizedBox(
                        height: 24),

                    buildCard(
                      title:
                        "Sybelle cafe",

                      image:
                        "assets/cafe.png",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String image,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,

            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(
              height: 12),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
                    20),

            child: Image.asset(
              image,

              height: 220,

              width:
                  double.infinity,

              fit:
                  BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.black26,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(
              height: 14),

          Row(
            children: [

              const Icon(
                Icons.star,

                color:
                    Color(0xFFD8A351),
              ),

              const SizedBox(
                  width: 8),

              const Text(
                "5/5",

                style:
                    TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.arrow_forward,
              ),
            ],
          )
        ],
      ),
    );
  }
}
