//
//  DownloadCleanupView.swift
//  Android Dev Assistant
//

import SwiftUI

struct DownloadCleanupView: View {

    @EnvironmentObject var adbHelper: AdbHelper
    @EnvironmentObject var uiController: UIController
    @EnvironmentObject var theme: ThemeManager

    @State var items: [DownloadApkItem]? = nil
    @State var selectedPaths: Set<String> = []
    @State var isDeleting = false
    @State var showDeleteConfirmation = false

    private var sortedItems: [DownloadApkItem] {
        (items ?? []).sorted { $0.date > $1.date }
    }

    var body: some View {
        PopupView(title: "Cleaner") {
            if let items {
                if items.isEmpty {
                    Text("No APK files found in Downloads")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        SelectionHeaderView()
                        Divider().opacity(0.3)
                        ApkListView()
                        if !items.isEmpty {
                            Divider().opacity(0.3)
                            DeleteButtonView()
                        }
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            adbHelper.listDownloadApks { result in
                items = result
            }
        }
        .alert("Delete Files", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Confirm", role: .destructive) {
                performDelete()
            }
        }
    }

}

// MARK: - Selection Header

extension DownloadCleanupView {

    private func SelectionHeaderView() -> some View {
        let allSelected = selectedPaths.count == items?.count && !(items?.isEmpty ?? true)
        return HStack {
            Button {
                if let items {
                    if allSelected {
                        selectedPaths.removeAll()
                    } else {
                        selectedPaths = Set(items.map(\.path))
                    }
                }
            } label: {
                Image(systemName: allSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(allSelected ? theme.accent : .secondary)
                    .font(.title3)
            }.buttonStyle(.plain)
                .hoverOpacity()
            Text("\(selectedPaths.count) of \(items?.count ?? 0) selected")
                .font(.callout)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

}

// MARK: - APK List

extension DownloadCleanupView {

    private func ApkListView() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                    ApkItemRow(item: item)
                    if index < sortedItems.count - 1 {
                        Divider().opacity(0.2).padding(.leading, 52)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollIndicators(.never)
    }

    private func ApkItemRow(item: DownloadApkItem) -> some View {
        let isSelected = selectedPaths.contains(item.path)
        return Button {
            if isSelected {
                selectedPaths.remove(item.path)
            } else {
                selectedPaths.insert(item.path)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(.secondary)
                    .font(.body)
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.fileName)
                        .font(.callout)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text(item.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.primary.opacity(0.00001))
        }.buttonStyle(.plain)
            .hoverOpacity()
    }

}

// MARK: - Delete Button

extension DownloadCleanupView {

    private func DeleteButtonView() -> some View {
        HStack {
            Button {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    if isDeleting {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Image(systemName: "trash")
                        Text("Delete \(selectedPaths.count) File(s)")
                    }
                }.padding(.all, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedPaths.isEmpty || isDeleting ? theme.surface : .red)
                ).foregroundStyle(selectedPaths.isEmpty || isDeleting ? Color.secondary : Color.white)
            }.buttonStyle(.plain)
                .disabled(selectedPaths.isEmpty || isDeleting)
                .hoverOpacity(selectedPaths.isEmpty || isDeleting ? 1 : HOVER_OPACITY)
                
        }.padding(.all, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func performDelete() {
        isDeleting = true
        adbHelper.deleteDownloadFiles(paths: Array(selectedPaths)) { count in
            isDeleting = false
            if count > 0 {
                ToastHelper.shared.addToast("Deleted \(count) file(s)", style: .success)
                uiController.showingPopup = nil
            } else {
                ToastHelper.shared.addToast("Delete failed", style: .error)
            }
        }
    }

}
