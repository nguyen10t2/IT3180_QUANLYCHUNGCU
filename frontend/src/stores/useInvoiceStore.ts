import { create } from "zustand";
import { persist } from "zustand/middleware";

export interface Invoice {
  id: number;
  title: string;
  amount: string; // formatted string like "500,000"
  dueDate: string;
  status: "pending" | "paid";
  paidAt?: string;
}

interface InvoiceState {
  invoices: Invoice[];
  setInvoices: (invoices: Invoice[]) => void;
  payInvoice: (id: number) => void;
  getPendingInvoices: () => Invoice[];
  getPaidInvoices: () => Invoice[];
  getTotalPending: () => number;
  getPendingCount: () => number;
}

// Initial hardcoded data (will be replaced by API later)
const initialInvoices: Invoice[] = [
  {
    id: 1,
    title: "Phí quản lý tháng 11/2025",
    amount: "500,000",
    dueDate: "30/11/2025",
    status: "pending",
  },
  {
    id: 2,
    title: "Phí điện nước tháng 11/2025",
    amount: "1,200,000",
    dueDate: "30/11/2025",
    status: "pending",
  },
  {
    id: 3,
    title: "Phí quản lý tháng 10/2025",
    amount: "500,000",
    dueDate: "30/10/2025",
    status: "paid",
    paidAt: "28/10/2025",
  },
  {
    id: 4,
    title: "Phí điện nước tháng 10/2025",
    amount: "980,000",
    dueDate: "30/10/2025",
    status: "paid",
    paidAt: "28/10/2025",
  },
];

export const useInvoiceStore = create<InvoiceState>()(
  persist(
    (set, get) => ({
      invoices: initialInvoices,

      setInvoices: (invoices) => set({ invoices }),

      payInvoice: (id) => {
        const today = new Date().toLocaleDateString("vi-VN");
        set((state) => ({
          invoices: state.invoices.map((invoice) =>
            invoice.id === id
              ? { ...invoice, status: "paid" as const, paidAt: today }
              : invoice
          ),
        }));
        // TODO: Call API to process payment
        // await invoiceService.payInvoice(id);
      },

      getPendingInvoices: () => {
        return get().invoices.filter((i) => i.status === "pending");
      },

      getPaidInvoices: () => {
        return get().invoices.filter((i) => i.status === "paid");
      },

      getTotalPending: () => {
        return get()
          .invoices.filter((i) => i.status === "pending")
          .reduce((sum, i) => sum + parseInt(i.amount.replace(/,/g, "")), 0);
      },

      getPendingCount: () => {
        return get().invoices.filter((i) => i.status === "pending").length;
      },
    }),
    {
      name: "invoice-storage",
    }
  )
);
