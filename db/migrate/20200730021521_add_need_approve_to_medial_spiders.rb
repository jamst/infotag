class AddNeedApproveToMedialSpiders < ActiveRecord::Migration[5.2]
  def change
    add_column :medial_spiders, :need_approve, :integer, default: 1, comment: "是否需要审核0自动审核unneed，1手动审核need"
  end
end
