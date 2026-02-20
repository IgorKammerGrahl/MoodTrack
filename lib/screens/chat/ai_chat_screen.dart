import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../controllers/ai_controller.dart';
import '../../widgets/mood_card.dart';

class AIChatScreen extends StatelessWidget {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AIController());

    // Listen for crisis modal
    ever(controller.showCrisisModal, (show) {
      if (show) {
        _showCrisisDialog(context);
        controller.showCrisisModal.value = false;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Chat com IA',
          style: AppTextStyles.h1.copyWith(fontSize: 18.sp),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Disclaimer Banner
          Container(
            padding: EdgeInsets.all(8.w),
            color: AppColors.secondary.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16.sp,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'A IA não substitui um profissional de saúde mental.',
                    style: AppTextStyles.body.copyWith(fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),

          // Typing Indicator
          Obx(
            () => controller.isTyping.value
                ? Padding(
                    padding: EdgeInsets.only(left: 16.w, bottom: 8.h),
                    child: Text(
                      'IA digitando...',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: controller.sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isUser ? 40.w : 0,
          right: isUser ? 0 : 40.w,
        ),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: AppTextStyles.body.copyWith(
            color: isUser ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }

  void _showCrisisDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Text('Você não está sozinho', style: AppTextStyles.h1),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Identificamos que você pode estar passando por um momento difícil. Existem pessoas prontas para te ouvir agora.',
              style: AppTextStyles.body,
            ),
            SizedBox(height: 24.h),
            MoodCard(
              backgroundColor: Color(0xFFFFE5E5),
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.red),
                title: Text(
                  'Ligar para o CVV',
                  style: AppTextStyles.h1.copyWith(fontSize: 16),
                ),
                subtitle: Text('188 - Disponível 24h'),
                onTap: () {
                  launchUrl(Uri(scheme: 'tel', path: '188'));
                  Get.back();
                },
              ),
            ),
            SizedBox(height: 12.h),
            MoodCard(
              backgroundColor: Color(0xFFFFE5E5),
              child: ListTile(
                leading: Icon(Icons.local_hospital, color: Colors.red),
                title: Text(
                  'Ligar para o SAMU',
                  style: AppTextStyles.h1.copyWith(fontSize: 16),
                ),
                subtitle: Text('192 - Emergências'),
                onTap: () {
                  launchUrl(Uri(scheme: 'tel', path: '192'));
                  Get.back();
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Fechar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
