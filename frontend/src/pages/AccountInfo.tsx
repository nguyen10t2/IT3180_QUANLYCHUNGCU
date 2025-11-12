import { useEffect, useState } from "react";
import { useAuthStore } from "@/stores/useAuthStore";
import type { User } from "@/types/user";
import { AccountInfoCard } from "@/components/ui/account-info-card";

interface AccountInfoProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function AccountInfo({ isOpen }: AccountInfoProps) {
  const { user, fetchMe, loading } = useAuthStore();
  const [userInfo, setUserInfo] = useState<User | null>(null);

  useEffect(() => {
    // Nếu modal được mở nhưng chưa có user, fetch lại
    if (isOpen && !user && !loading) {
      fetchMe();
    }
  }, [isOpen, user, loading, fetchMe]);

  useEffect(() => {
    if (user) {
      setUserInfo(user);
    }
  }, [user]);

  if (!isOpen) return null;

  // Hiển thị loading khi đang fetch user
  if (!userInfo && loading) {
    return (
      <div className="ml-64 p-8 flex-1">
        <div className="max-w-sm bg-card border border-border rounded-lg shadow-sm p-6">
          <div className="flex items-center justify-center py-8">
            <div className="text-muted-foreground">Đang tải thông tin...</div>
          </div>
        </div>
      </div>
    );
  }

  if (!userInfo) return null;

  const handleChangePassword = () => {
    // TODO: Implement change password logic
    console.log("Change password clicked");
  };

  const handleEditInfo = () => {
    // TODO: Implement edit info logic
    console.log("Edit info clicked");
  };

  return (
    <div className="ml-64 p-8 flex-1">
      <AccountInfoCard
        user={userInfo}
        onChangePassword={handleChangePassword}
        onEditInfo={handleEditInfo}
      />
    </div>
  );
}