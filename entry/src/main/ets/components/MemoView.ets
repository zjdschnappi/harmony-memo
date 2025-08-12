
interface MemoItem {
  title: string;
  content?: string
  time: string
}

@Component
export default struct MemoView {
  @Prop list:MemoItem[] = [{title:'标题1',time:'1分钟前'}]
  build(){
    //
    List(){
      ForEach(this.list,(item:MemoItem)=>{
        ListItem(){
          Column(){

            Text(item.title).fontSize(18).fontWeight(700)

            Text(item.time).fontSize(12)
          }.width('100%').alignItems(HorizontalAlign.Start).border({
            width:{
              bottom: 1
            },
            color: '#dfdfdf'
          }).padding({left:10,right:10,top: 5, bottom: 5})

        }
      })
    }.height('100%')


  }
}