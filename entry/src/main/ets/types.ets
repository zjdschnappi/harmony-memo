
export interface IRectInfoInPx {
  left: number
  top: number
  right: number
  bottom: number
  width: number
  height: number
}

export interface IMemoRouteParam {
  id: string;
  doDefaultTransition?:()=>void;
  itemRectInfo?: IRectInfoInPx
}

export interface IColorItemParams {
  color:Color|string
  onClick:(item:Color|string)=>void
}

export interface ITextDecoratorItem{
  icon: Resource;
  type: 'underline'|'italic'|'bold'|'textAlignLeft'|'textAlignCenter'|'textAlignRight';
  active?:boolean;
}
export interface ITextDirectionItem{
  icon: Resource;
  onClick:()=>void;
  active?:boolean;
}
export interface ITextColorItem{
  color: Color|string;
}
export interface ITypingStyleParam{
  textColor?: Color|string;
  fontSize?: number;
  isBold?: boolean;
  isItalic?: boolean;
  isUnderline?: boolean;
}
