import { Navigate, Outlet } from "react-router"
import { useAuthStore } from "@/stores/useAuthStore"
import { useEffect, useState, useRef } from "react"

const ProtectedRoute = () => {
  const { accessToken, loading, refreshTokenHandler, fetchMe } = useAuthStore()
  const [starting, setstarting] = useState(true)
  const [isAuthenticated, setIsAuthenticated] = useState(false)
  const hasInitialized = useRef(false)

  const init = async () => {
    try {
      // Nếu chưa có accessToken, thử refresh
      if (!accessToken) {
        await refreshTokenHandler()
      }

      // Sau khi refresh, lấy lại state mới
      const currentState = useAuthStore.getState()
      const currentToken = currentState.accessToken
      const currentUser = currentState.user
      
      if (currentToken) {
        setIsAuthenticated(true)
        
        // Lấy thông tin user nếu chưa có
        if (!currentUser) {
          await fetchMe()
        }
      } else {
        // Không có token sau khi refresh -> chưa đăng nhập
        setIsAuthenticated(false)
      }
    } catch (error) {
      console.error("Auth init error:", error)
      setIsAuthenticated(false)
    } finally {
      setstarting(false)
    }
  }

  useEffect(() => {
    if (location.pathname === "/signin" || location.pathname === "/signup") {
      setstarting(false)
      return
    }
    
    // Chỉ chạy init một lần, tránh double call từ StrictMode
    if (hasInitialized.current) {
      return
    }
    
    hasInitialized.current = true
    init()
  }, [])

  if (starting || loading) {
    return <div className="flex h-screen items-center justify-center">Đang tải trang...</div>
  }

  if (!isAuthenticated && !accessToken) {
    return (
      <Navigate
        to="/signin"
        replace
      />
    )
  }
  return (
    <Outlet></Outlet>
  )
}

export default ProtectedRoute
