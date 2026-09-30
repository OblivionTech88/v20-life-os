export const habitRate=(done:number,expected:number)=>expected?Math.min(100,done/expected*100):0
export const dailyStreak=(days:boolean[])=>days.reduce((n,done)=>done?n+1:0,0)
export const sleepHours=(bed:string,wake:string)=>{const [bh,bm]=bed.split(':').map(Number),[wh,wm]=wake.split(':').map(Number);let m=wh*60+wm-(bh*60+bm);if(m<0)m+=1440;return m/60}
export const disciplineScore=(items:{score:number;weight:number;applicable:boolean}[])=>{const active=items.filter(x=>x.applicable);const total=active.reduce((n,x)=>n+x.weight,0);return total?active.reduce((n,x)=>n+x.score*x.weight,0)/total:0}
