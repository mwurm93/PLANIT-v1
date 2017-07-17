//  Converted with Swiftify v1.0.6402 - https://objectivec2swift.com/
class HLPlaceholderCell: HLResultCardCell {
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        //    self.resetButton.titleLabel.font = [UIFont appMediumFontWithSize:14.0];
        //    [self.resetButton setTitleColor:[[ColorScheme current] mainAppColor] forState:UIControlStateNormal];
        //    self.titleLabel.font = [UIFont appMediumFontWithSize:18.0];
    }

    @IBAction func dropFilters() {
        item.filter?.dropFilters()
    }
}