import { redirect } from "next/navigation";

export default function Home() {
  // Redirect to signin page by default
  redirect("/signin");
}
