import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:fridgeiq/features/auth/domain/entities/app_user.dart';
import 'package:fridgeiq/features/auth/presentation/providers/auth_providers.dart';
import 'package:fridgeiq/features/family/domain/entities/family.dart';
import 'package:fridgeiq/features/family/presentation/providers/family_providers.dart';

/// Provider that fetches AppUser objects for all members of a family by its ID.
final familyMembersProvider =
    FutureProvider.family<List<AppUser>, String>((ref, familyId) async {
  final familyRepo = ref.read(familyRepositoryProvider);
  final family = await familyRepo.getFamilyById(familyId);
  if (family == null) return [];
  final authRepo = ref.read(authRepositoryProvider);
  final futures = family.memberIds.map((id) => authRepo.getUserById(id));
  final results = await Future.wait(futures);
  return results.whereType<AppUser>().toList();
});

class FamilyDrawer extends ConsumerWidget {
  const FamilyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final familiesAsync = ref.watch(userFamiliesProvider);
    final currentFamilyId = ref.watch(currentFamilyIdProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primary,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Icon(Icons.person,
                            color: colorScheme.onPrimary, size: 28)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'User',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
            // Families section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Families',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, size: 20),
                    onPressed: () => _showCreateJoinDialog(context, ref),
                    tooltip: 'Create or join family',
                  ),
                ],
              ),
            ),
            Expanded(
              child: familiesAsync.when(
                data: (families) {
                  if (families.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.family_restroom,
                              size: 48, color: colorScheme.outline),
                          const SizedBox(height: 8),
                          Text(
                            'No families yet',
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: families.length,
                    itemBuilder: (context, index) {
                      final family = families[index];
                      final isActive = family.id == currentFamilyId;
                      final isCreator = user != null && family.createdBy == user.id;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.family_restroom,
                            color: isActive
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                family.name,
                                style: TextStyle(
                                  fontWeight:
                                      isActive ? FontWeight.bold : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCreator) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.star, size: 14, color: colorScheme.primary),
                            ],
                          ],
                        ),
                        subtitle: Text(
                            '${family.memberIds.length} member${family.memberIds.length != 1 ? 's' : ''}'),
                        trailing: isActive
                            ? Icon(Icons.check_circle,
                                color: colorScheme.primary)
                            : null,
                        selected: isActive,
                        onTap: () {
                          ref
                              .read(currentFamilyIdProvider.notifier)
                              .setFamily(family.id);
                          Navigator.pop(context);
                        },
                        onLongPress: () =>
                            _showFamilyOptions(context, ref, family, user),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
            const Divider(),
            // Sign out
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                Navigator.pop(context);
                ref.read(currentFamilyIdProvider.notifier).clear();
                await ref.read(authStateProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateJoinDialog(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _CreateJoinFamilySheet(),
    );
  }

  void _showFamilyOptions(
      BuildContext context, WidgetRef ref, Family family, AppUser? user) {
    final isCreator = user != null && family.createdBy == user.id;
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show members section
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Members'),
              subtitle: Text('${family.memberIds.length} member${family.memberIds.length != 1 ? 's' : ''}'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showMembersDialog(context, ref, family, user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Invite Code'),
              subtitle: Text(family.inviteCode),
              onTap: () {
                Clipboard.setData(ClipboardData(text: family.inviteCode));
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Invite code "${family.inviteCode}" copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            if (!isCreator)
              ListTile(
                leading: Icon(Icons.exit_to_app,
                    color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Leave Family',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pop(context); // close drawer
                  _confirmLeaveFamily(context, ref, family);
                },
              ),
            if (isCreator)
              ListTile(
                leading: Icon(Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Delete Family',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pop(context); // close drawer
                  _confirmDeleteFamily(context, ref, family);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showMembersDialog(
      BuildContext context, WidgetRef ref, Family family, AppUser? user) {
    final isCreator = user != null && family.createdBy == user.id;
    showDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, dialogRef, _) {
          final membersAsync =
              dialogRef.watch(familyMembersProvider(family.id));
          return AlertDialog(
            title: Text('${family.name} - Members'),
            content: SizedBox(
              width: double.maxFinite,
              child: membersAsync.when(
                data: (members) => ListView.builder(
                  shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isMemberCreator = member.id == family.createdBy;
                    final isCurrentUser = user != null && member.id == user.id;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: member.photoUrl != null
                            ? NetworkImage(member.photoUrl!)
                            : null,
                        child: member.photoUrl == null
                            ? Text(member.displayName.isNotEmpty
                                ? member.displayName[0].toUpperCase()
                                : '?')
                            : null,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMemberCreator) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.star, size: 16, color: Theme.of(context).colorScheme.primary),
                          ],
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4),
                            const Text(' (you)',
                                style: TextStyle(
                                    fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ],
                      ),
                      subtitle: Text(member.email),
                      trailing: isCreator && !isMemberCreator && !isCurrentUser
                          ? IconButton(
                              icon: Icon(Icons.person_remove,
                                  color: Theme.of(context).colorScheme.error),
                              tooltip: 'Remove from family',
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                Navigator.pop(context); // close drawer
                                _confirmRemoveMember(
                                    context, ref, family, member);
                              },
                            )
                          : null,
                    );
                  },
                ),
                loading: () => const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Failed to load members: $e'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLeaveFamily(
      BuildContext context, WidgetRef ref, Family family) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Family'),
        content: Text(
            'Are you sure you want to leave "${family.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(userFamiliesProvider.notifier)
                  .leaveFamily(family.id);
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteFamily(
      BuildContext context, WidgetRef ref, Family family) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Family'),
        content: Text(
            'Are you sure you want to delete "${family.name}"? All members will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(userFamiliesProvider.notifier)
                  .deleteFamily(family.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveMember(
      BuildContext context, WidgetRef ref, Family family, AppUser member) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
            'Are you sure you want to remove "${member.displayName}" from "${family.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(userFamiliesProvider.notifier)
                  .removeMember(family.id, member.id);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _CreateJoinFamilySheet extends ConsumerStatefulWidget {
  const _CreateJoinFamilySheet();

  @override
  ConsumerState<_CreateJoinFamilySheet> createState() =>
      _CreateJoinFamilySheetState();
}

class _CreateJoinFamilySheetState
    extends ConsumerState<_CreateJoinFamilySheet> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add Family',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Create New Family',
                prefixIcon: Icon(Icons.group_add),
                hintText: 'Family name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _isLoading ? null : _create,
              child: const Text('Create'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.outline)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Join with Invite Code',
                prefixIcon: Icon(Icons.vpn_key),
                hintText: 'ABC123',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isLoading ? null : _join,
              child: const Text('Join'),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(userFamiliesProvider.notifier).createFamily(name);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create family. Please try again.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final family =
          await ref.read(userFamiliesProvider.notifier).joinFamily(code);
      if (family == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid invite code'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to join family. Please try again.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
