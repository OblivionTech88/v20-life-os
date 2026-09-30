export const sum=(xs:number[])=>xs.reduce((a,b)=>a+b,0)
export const monthlyBalance=(income:number[],expenses:number[])=>sum(income)-sum(expenses)
export const debtBalance=(initial:number,payments:number[])=>Math.max(0,initial-sum(payments))
export const debtProgress=(initial:number,payments:number[])=>initial?((initial-debtBalance(initial,payments))/initial)*100:100
export const reserveBalance=(entries:{type:'deposit'|'withdrawal'|'adjustment';amount:number}[])=>entries.reduce((n,e)=>n+(e.type==='withdrawal'?-e.amount:e.amount),0)
export const netWorth=(assets:number[],investments:number[],debts:number[])=>sum(assets)+sum(investments)-sum(debts)
export const businessProfit=(revenue:number,expenses:number)=>revenue-expenses
export const ratio=(value:number,total:number)=>total?value/total*100:0
export function freedomProgress(c:{profit:boolean;reserve:boolean;debts:boolean;mrr:boolean;consistency:boolean;pipeline:boolean}){return Object.values(c).filter(Boolean).length/6*100}
