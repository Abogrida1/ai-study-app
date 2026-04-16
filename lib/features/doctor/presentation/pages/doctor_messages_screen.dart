import 'package:flutter/material.dart';
import '../../../../core/app_localizations.dart';
import '../../../student/presentation/pages/chat_detail_screen.dart';

class DoctorMessagesScreen extends StatelessWidget {
  const DoctorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header / Title & Search
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.translate('messages'),
                    style: textTheme.headlineLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.translate('search_messages_hint'),
                        hintStyle: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.outline.withOpacity(0.6),
                        ),
                        prefixIcon: Icon(Icons.search, color: colorScheme.outline),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                l10n.translate('direct_conversations').toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // Conversations List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMessageItem(
                  context,
                  name: 'Dr. Sarah Jenkins',
                  message: "I've attached the preliminary results from the lab.",
                  time: '10:24 AM',
                  unreadCount: 2,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuARdIkhmQN2gU0AbeiceR_aWlOYPCHILwv5QfkgG7YUtJ1vmZ-2CHbbrTewkP-muswjW6XORNFbOnJjFavywAus_hLsEnetN3fMoyMSEu7qBzDa07jcq2h0qXTwVrSwTmEmkoHsiR-IIbTCMkFw2T1t0FTMD5hTnoBgvk1kPfwu4hmV9yWvB4of_3UbsBs22djDzEfYeJJZ0yP4gsDXQgjyWW86krJAylevupKRi7Jv8fx4A_uMmD1mdBQ9f0TDrTxsLipgbOu7fSva',
                  isOnline: true,
                ),
                _buildMessageItem(
                  context,
                  name: 'Dean Michael Thorne',
                  message: "The faculty meeting has been rescheduled to Friday at 3:00 PM.",
                  time: 'Yesterday',
                  unreadCount: 0,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB0Qn1qPk1AQyC62EWDWyn1C3Sgq2ZQOWy5fAjEvNyQL0SX2-DwDPOpTcf3B6fCXwvuWVGrp6596f0_JqGezYe7tyaKC6mkT3OezJN9MGhsr63QKaKr2DFex2-xqQk2dUG3T2-wHujZsUfrMF-ZRbiiCaesz34exDOF9rrk9XaYCr5FhecnOQPYEdEA2dFwSCjmAx9BTDuoSfDmpO4wA5ZEKx23ULyeDu_VE_T1Zc_Cx--raTl1fcgiQEuWumXklFVaNnCI2dvYHwIe',
                  isOnline: false,
                ),
                _buildMessageItem(
                  context,
                  name: 'Curriculum Board 2024',
                  message: "Professor Chen added 3 new files to the shared folder.",
                  time: 'Tue',
                  unreadCount: 1,
                  isGroup: true,
                  isOnline: false,
                ),
                _buildMessageItem(
                  context,
                  name: 'Elena Rodriguez',
                  message: "Thank you for the feedback on my thesis proposal.",
                  time: 'Mon',
                  unreadCount: 0,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCSD0GZGMkhHC161XJDIf2AlgycTsX4AMHmR-YXeZwRH8MgQtcSIGuBjFzI9voqfWZWt81cJH-I373hq26YLKVg1Gtf2Ja4tn5CfOaYTr4ODfxqFlMMHxHN8fh5IMAg_UltF6KVxbwPt5OaUfjp31WJkWKdkwpw1sBX5FhY9CvbT8c2rMYT_WHKsuzie4yJZJbbVsTwoDWw5PqiQJIp_YDW41GJn_0EpVLpqdv9uuDDo_3o0FrcDaxEdXnoOjQD2Vzfj09Uq2c3xqSG',
                  isOnline: false,
                ),
                _buildMessageItem(
                  context,
                  name: 'Dr. Aisha Khan',
                  message: "Shall we proceed with the grant application for the humanities project?",
                  time: 'May 12',
                  unreadCount: 0,
                  imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCKMfs4CfYnzchvbOh0UCuM3mD05Yyea7xWlJyuGebmaQRhkdvwJaQ0P7_gssJTHxUGZPAW4VLaJdLzZKTazeUjBqVA1EKlN_1LKOHJTQ9cWHVDqcf7JbcBE8_8f8_ktjk-i1GVdAjvYt51YVSwhbbPe8aywxSx8Ih_nCMJt-n5mqr-AsJ7exIqnHTDFmNOgD5zyyeI_qhR7ggzWdSb_u_92GrDfEcpQBW5TWFo4-umIz75I_6updpBMN96e-AEI4-Wfsk2Kh6bZpIa',
                  isOnline: false,
                ),
              ]),
            ),
          ),
          
          // Extra bottom space for Nav Bar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), // Fixed above custom nav bar
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: colorScheme.primary,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageItem(
    BuildContext context, {
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    String? imageUrl,
    bool isOnline = false,
    bool isGroup = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                chatName: name,
                chatRole: isGroup ? 'Group' : 'Student',
                avatarUrl: imageUrl ?? 'https://via.placeholder.com/150',
                isOnline: isOnline,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Avatar Stack
            Stack(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isGroup ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHigh,
                    image: (!isGroup && imageUrl != null)
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: isGroup
                      ? Icon(Icons.groups_rounded, color: colorScheme.onSecondaryContainer, size: 28)
                      : (imageUrl == null ? Icon(Icons.person, color: colorScheme.onSurfaceVariant) : null),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Name and Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: textTheme.labelSmall?.copyWith(
                          fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          color: unreadCount > 0 ? colorScheme.primary : colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            color: unreadCount > 0 ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
