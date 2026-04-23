import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/chat_repository.dart';
import 'dart:async';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatConnected extends ChatEvent {
  final String roomId;
  final String token;
  const ChatConnected(this.roomId, this.token);
}

class ChatMessageReceived extends ChatEvent {
  final Map<String, dynamic> message;
  const ChatMessageReceived(this.message);
}

class ChatMessageSent extends ChatEvent {
  final String message;
  const ChatMessageSent(this.message);
}

// States
enum ChatStatus { initial, loading, connected, failure }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<dynamic> messages;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<dynamic>? messages,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  StreamSubscription? _subscription;

  ChatBloc({required this.chatRepository}) : super(const ChatState()) {
    on<ChatConnected>(_onConnected);
    on<ChatMessageReceived>(_onMessageReceived);
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onConnected(ChatConnected event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final history = await chatRepository.getChatHistory(event.roomId);
      emit(state.copyWith(status: ChatStatus.connected, messages: history.reversed.toList()));

      await _subscription?.cancel();
      _subscription = chatRepository.connect(event.roomId, event.token).listen((msg) {
        add(ChatMessageReceived(msg));
      });
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.failure, errorMessage: e.toString()));
    }
  }

  void _onMessageReceived(ChatMessageReceived event, Emitter<ChatState> emit) {
    final updatedMessages = List.from(state.messages)..insert(0, event.message);
    emit(state.copyWith(messages: updatedMessages));
  }

  void _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) {
    chatRepository.sendMessage(event.message);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    chatRepository.disconnect();
    return super.close();
  }
}
