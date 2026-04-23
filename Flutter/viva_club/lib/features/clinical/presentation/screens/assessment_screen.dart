import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/clinical_bloc.dart';
import '../bloc/clinical_event.dart';
import '../bloc/clinical_state.dart';
import '../clinical_constants.dart';
import 'package:go_router/go_router.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Assessment'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<ClinicalBloc, ClinicalState>(
        listener: (context, state) {
          if (state.status == ClinicalStatus.success && state.riskLevel != null) {
            context.push('/clinical/result');
          }
        },
        builder: (context, state) {
          final progress = (state.currentQuestionIndex) / ClinicalConstants.phq9Questions.length;

          return Column(
            children: [
              // Progress Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                      minHeight: 8.h,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Question ${state.currentQuestionIndex + 1} of ${ClinicalConstants.phq9Questions.length}',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ClinicalConstants.phq9Questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(index, state);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(int index, ClinicalState state) {
    final question = ClinicalConstants.phq9Questions[index];

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),
          SizedBox(height: 32.h),
          ...List.generate(ClinicalConstants.phq9Options.length, (optionIndex) {
            final isSelected = state.answers[index] == optionIndex;
            return GestureDetector(
              onTap: () {
                context.read<ClinicalBloc>().add(
                  AssessmentAnswered(questionIndex: index, score: optionIndex),
                );
                
                if (index < ClinicalConstants.phq9Questions.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  context.read<ClinicalBloc>().add(const AssessmentSubmitted());
                }
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[400]!,
                          width: 2,
                        ),
                        color: isSelected ? const Color(0xFF6C63FF) : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        ClinicalConstants.phq9Options[optionIndex],
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
